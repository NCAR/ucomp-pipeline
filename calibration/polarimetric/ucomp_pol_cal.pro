pro UCoMP_Pol_Cal,date_str
;+
;  Description:
;    Procedure to read and perform polarimatric calibration of UCoMP data. This is the main routine
;    for polarimetric calibration of the UCoMP. This procedure calls UCoMP_Fit_Pol_Cal which performs
;    the actual calibrations. This routine will analyze all of the polarization calibrations on a single day.
;
;    Formulation is based on del Toro Iniesta & Collados, App. Opt. 39, 2000 and
;    the presentation by deWijn "The Concept of Optimal Calibration".
;    See UCoMP Calibration writeup for details and references
;
;  Input:  date_str - date (string) to analyze (yyyymmdd)
;
;
;  Definitions:
;    Cmatrix - Calibration matrix [ncal,4]
;    Ematrix - E matrix is the nominal inverse of C as described by deWijn [4,ncal]
;    Omatrix - the modulation matrix [4,nmod]
;    Dmatrix - the demodulation matrix [nmod,4]
;
;    Imeas - calibration observations [ncal columns x nmod rows] comprised of the nmod modulated intensities
;      obtained by observing the ncal calibration states
;
;    nmod - the number of modulation states (4 for UCoMP)
;    ncal - the number of calibration states (e.g. orientations of the cal polarizer, cal retarder, clear)
;
;    Note that calibration retarder has a nominal retardance of quarter-wave at 750 nm
;
;    The polarization sequence steps through the calibration states alternating Rcam, Tcam transmission
;    Then there are 2*ncal extensions to the fits files
;-
common pol_fit,Imeas,pol_angle,ret_angle,cal_inout,wave

compile_opt strictarr

debug = 'no'       ;debug mode ('yes' or 'no')
ans = ' ' & str = ' '

dir = '/home/mgalloy/projects/UCOMP/Integration and Testing/Polarimetric Calibration/'     ;go to analysis directory
cd,dir

;  open log file

openw,3,'/home/mgalloy/projects/UCOMP/Integration and Testing/Data Processing/Log Files/'+date_str+'_log.txt',/append
printf,3,' '
printf,3,date_str,' Start Pol Cal  ',systime()

data_dir = '/hao/dawn/Data/UCoMP/incoming/'+date_str+'/'                               ;set data directory
if  file_test(data_dir,/directory) ne 1 then begin                 ;check for existence of directory
  printf,3,'data directory does not exist'
  goto,skip_this_day
endif

nx = 1280       ;x-pixels
ny = 1024       ;y-pixels
nmod = 4        ;number of modulation states
sat_level = 2600.     ;saturation level above dark (DN)

;    creat annulus mask to select region to analyze

mask = ucomp_annulus(355.,500.)       ;r1, r2 (annulus from r1 to r2)

;  get linearity coefficients

;lin_file = string(format='("cam",i1,"_linearity.sav")',cam)
;restore,file=lin_file
;lin_cof = c

;  read catalog of files for this day

UCoMP_Read_Catalog_File,date_str,files,num_exts,num_sums,type,exposures,gains,wave_regions,num_waves,times

cals = where(type eq 'cal',ncal)         ;identify cal files
if ncal eq 0 then cals = where(num_exts eq 18 and num_waves eq 1,ncal)

if ncal eq 0 then begin
  printf,3,'***** No Calibration Files On This Day *****'
  goto,skip_this_day
endif

cal_files = data_dir+files[cals]

;  identify associated dark files (closest dark in time before cal file)

darks = where(type eq 'dark',ndark)
cal_dark = strarr(ncal)
for i=0,ncal-1 do begin
  dtime = times[darks]-times[cals[i]]       ;find dark closest in time (largest negative time difference)
  before = where(dtime lt 0.)
  closest = max(dtime[before],imax)
  cal_dark[i] = files[darks[before[imax]]]
endfor

;    open results file

openw,1,dir+'Results.mine/'+date_str+'.txt'          ;open output file
printf,1

if debug eq 'yes' then print,ncal,' calibration files this day'
printf,1,ncal,' calibration files this day'

;if debug eq 'yes' then for i=0,ncal-1 do print,cal_files[i],'    ',cal_dark[i]

;    open postscript file

openpost,dev,file=dir+'Results.mine/'+date_str+'.ps',default='p',/no_ask        ;open ps file or output to screen

if dev eq 'p' then device,/landscape else begin
  window,0,xs=800,ys=600
  window,2,xs=nx/2,ys=ny/2        ;display dark images
endelse
!p.multi = [0,2,2,0,0]

;  create arrays to hold results

pol_eff = fltarr(4,ncal)
cal_eff = fltarr(4,ncal)
waves = fltarr(ncal)
trans = fltarr(ncal)
cal_ret = fltarr(ncal)
offset = fltarr(ncal)
fit_rms = fltarr(ncal)
dmatrices = fltarr(nmod,4,ncal)
mod_temp = fltarr(ncal)
u_mod_temp = fltarr(ncal)

for i=0,ncal-1 do begin      ;------------- loop over all calibration files -------------

    printf,1

 ;  read dark images for this cal file

    dark_file = data_dir+cal_dark[i]
    if debug eq 'yes' then print,'dark file: ',dark_file
    printf,1,'dark file: ',dark_file


    fits_open,dark_file,dark_fcb
    nex = dark_fcb.nextend     ;get number of extensions
    dark = fltarr(nx,ny,2)      ;array to hold dark average for each camera

;    average dark images over the modulation state and the extensions
;    temporary test to see if skipping first dark extension makes a difference (test2)

    for j=0,nex-1 do begin
        fits_read,dark_fcb,dat,dark_header,exten_no=j+1      ;read dark images
        numsum = sxpar(dark_header,'NUMSUM')
        data = float(dat)/float(numsum)
        data = total(data,3)/4.     ;average dark image over modulation state, dimension=3
        dark = dark + data
    endfor
    dark = dark/float(nex)
    fits_close,dark_fcb

    dark_expose = sxpar(dark_header,'EXPTIME')
    shut_stat = sxpar(dark_header,'DARKSHUT')       ;check that dark shutter is in beam
    if shut_stat ne 'in' then begin
        print,'>>>>> SHUTTER NOT IN FOR DARK <<<<<'
        goto,skip_this_day
    endif

;  read polarization data

    print,'data file:',cal_files[i]
    printf,1,'data file:',cal_files[i]

    fits_open,cal_files[i],fcb
    nex = fcb.nextend       ;number of extensions (number of calibration states is half of this)

;  loop over all extensions. The number of calibrations states and read all calibration states

    pol_angle = fltarr(nex)
    ret_angle = fltarr(nex)
    cal_inout = strarr(nex)
    onband = strarr(nex)
    contin = strarr(nex)
    intens = fltarr(nex,nmod,2)           ;array for measured intensities for all extensions, modulation states and cameras
    fits_read, fcb, primary_data, primary_header, exten_no=0
    for iex=0,nex-1 do begin

        fits_read,fcb,dat,header,exten_no=iex+1
        numsum = sxpar(header,'NUMSUM')
        mod_temp[i] = sxpar(primary_header,'T_MOD')              ;extract  modulator temperature for saving
        u_mod_temp[i] = sxpar(primary_header,'TU_MOD')              ;extract  unfiltered modulator temperature for saving
        if iex eq nex-1 then begin
            print,'Unfiltered Temperature:' ,u_mod_temp[i]
            printf,1,'Unfiltered Temperature:' ,u_mod_temp[i]
        endif

        data = float(dat)/float(numsum)                       ;divide by number of sums

      for ii=0,nmod-1 do for icam=0,1 do begin       ;camera (0=Rcam, 1=Tcam)
          data[*,*,ii,icam] = data[*,*,ii,icam]-dark[*,*,icam]     ;subtract dark
          d = data[*,*,ii,icam]
          intens[iex,ii,icam] = mean(d[where(mask gt 0.)])       ;compute intensity over mask
      endfor

      if iex eq 0 then begin
          wave = float(sxpar(header,'WAVELNG'))      ;get wavelength of polarization data
          print,' Wavelength:',wave
          printf,1,'Wavelength:',wave
          waves[i] = wave
      endif

      pol_angle[iex] = sxpar(header,'POLANGLE')
      ret_angle[iex] = sxpar(header,'RETANGLE')
      cal_inout[iex] = sxpar(header,'CALOPTIC')
      onband[iex] = sxpar(header,'ONBAND')        ;get which camera is on band
      contin[iex] = sxpar(header,'CONTIN')        ;get location of continuum channel

;  linearize signal
    ;data = poly(data,lin_cof)

;  find average signal in annulus above limb and display images

      if dev ne 'p' then wset,2
      for ii=0,3 do begin
          if debug eq 'yes' and dev ne 'p' then begin
              rd = bytscl(rebin(mask*data[*,*,ii,0],nx/4,ny/4),0,400)       ;display just camera 0
              tv,rd,ii
          endif
      endfor

    endfor
    fits_close,fcb


;       --------------   perform calibration    ---------------

;  average data over cameras and background mode, assume data alternates Tcam and Rcam

    ncal = nex/2        ;the number of calibration states is the number of extensions/2 (alternating Tcam, Rcam)
    Imeas = fltarr(ncal,nmod)
    for jj=0,ncal-1 do for ii=0,nmod-1 do Imeas[jj,ii] = (intens[jj*2,ii,0]+intens[jj*2+1,ii,0]+intens[jj*2,ii,1]+intens[jj*2+1,ii,1])/4.

    good = where(onband eq 'tcam')
    pol_angle = -pol_angle[good]      ;change sign of pol_angle since it rotates cw for positive angle
    ret_angle = ret_angle[good]
    cal_inout = cal_inout[good]

;  plot intensities

    if dev ne 'p' then wset,0
    for ii=0,3 do begin
        str = string(format='("Modulation State",i2)',ii)
        plot,Imeas[*,ii],xtit='Calibration State',ytit='Counts (DN)',psym=4,title=str,chars=1.2
        oplot,[0,nex],[sat_level,sat_level],linesty=2
        if ii eq 0 then xyouts,0.13,0.9,/norm,string(format='(f7.1)',wave),chars=1.5
    endfor
    if dev ne 'p' then read,'enter return',ans

;  normalize intensities by maximum intensity

    mx = max(Imeas)
    Imeas = Imeas/mx

;  calculate calibration matrices with default values
;
;  Sc = [1.,0.,0.,0.]        ;Stokes vector input to calibration optics
;  delta = 90.*750./wave      ;retardance of cal retarder (deg)
;  cal_trans = 0.40           ;calibration optics transmission
;
;  UCoMP_Calculate_Matrices,Sc,delta,cal_trans,pol_angle,ret_angle,cal_inout,Imeas,Dmatrix,$
;    Cmatrix=Cmatrix,Ematrix=Ematrix,Omatrix=Omatrix,pol_eff=p_eff,cal_eff=c_eff
;
;  Scal = Dmatrix##Imeas   ;demodulate measured calibration intensities and obtain calibration Stokes vectors

;  perform calibration fit

    UCoMP_Fit_Pol_Cal,Sc,delta,cal_trans,ret_offset,Dmatrix

    Scal = Dmatrix##Imeas   ;demodulate measured calibration intensities and obtain calibration Stokes vectors

    UCoMP_Calculate_Matrices,Sc,delta,cal_trans,pol_angle,ret_angle+ret_offset,cal_inout,Imeas,Dmatrix,$
      Cmatrix=Cmatrix,Ematrix=Ematrix,Omatrix=Omatrix,pol_eff=p_eff,cal_eff=c_eff

    rms = sqrt( total( (Cmatrix - Scal)^2 )/float(n_elements(Cmatrix)) )    ;rms error of fit

;  save values for plotting and save file

    pol_eff[*,i] = p_eff
    cal_eff[*,i] = c_eff
    trans[i] = cal_trans
    cal_ret[i] = delta
    offset[i] = ret_offset
    fit_rms[i] = rms
    dmatrices[*,*,i] = Dmatrix

;  plot Stokes vectors

    if dev ne 'p' then wset,0
    sstr = ['Stokes I','Stokes Q','Stokes U','Stokes V']
    for ii=0,3 do begin
        if ii eq 0 then $
          plot,Cmatrix[*,ii],xtit='Calibration State',ytit='Signal (Normalized Intensity)',psym=4,title=sstr[ii],chars=1.2,yr=[0.,1.],ysty=1 $
        else plot,Cmatrix[*,ii],xtit='Calibration State',ytit='Signal (Normalized Intensity)',psym=4,title=sstr[ii],chars=1.2,yr=[-0.5,.5],ysty=1
        oplot,Scal[*,ii]
        if ii eq 0 then xyouts,0.5,0.85,string(format='(f7.1)',wave),chars=1.5
    endfor
    if dev ne 'p' then read,'enter return',ans

;  print matrices, etc.

    printf,1,format='("rms:",f10.5)',rms
    printf,1,format='("Sc:",4f10.5)',Sc
    printf,1,format='("delta:",f10.5)',delta
    printf,1,format='("cal_trans:",f10.5)',cal_trans
    printf,1,format='("ret_offset:",f10.5)',ret_offset

    if debug eq 'yes' then begin
        printf,1,'Polarizer Angle:'
        printf,1,format='(9f10.5)',pol_angle
        printf,1,'Retarder Angle:'
        printf,1,format='(9f10.5)',ret_angle
        printf,1,'Cal In/Out:'
        printf,1,format='(9a10)',cal_inout
        printf,1,'intens:'
        for ii=0,nmod-1 do printf,1,format='(9f10.5)',intens[*,ii,0]
        for ii=0,nmod-1 do printf,1,format='(9f10.5)',intens[*,ii,1]
    endif

    printf,1,'Imeas:'
    for ii=0,nmod-1 do printf,1,format='(9f10.5)',Imeas[*,ii]
    printf,1,'Cmatrix:'
    for ii=0,3 do printf,1,format='(9f10.5)',Cmatrix[*,ii]
    Bmatrix = Cmatrix##transpose(Cmatrix)       ;compute B matrix
    B_invert = invert(Bmatrix,status,/double)
    printf,1,'B_invert:'
    for ii=0,3 do printf,1,format='(4f10.5)',B_invert[*,ii]
    printf,1,'Ematrix:'
    for ii=0,ncal-1 do printf,1,format='(9f10.5)',Ematrix[*,ii]
    printf,1,'Omatrix:'
    for ii=0,nmod-1 do printf,1,format='(9f10.5)',Omatrix[*,ii]
    printf,1,'Dmatrix:'
    for ii=0,3 do printf,1,format='(9f10.5)',Dmatrix[*,ii]
    printf,1,'Cal Stokes Vectors:'
    for ii=0,3 do printf,1,format='(9f10.5)',Scal[*,ii]

    printf,1,'Pol Efficiencies:'
    printf,1,format='(9f10.5)',p_eff
    printf,1,'Cal Efficiencies:'
    printf,1,format='(9f10.5)',c_eff
endfor

;  plot efficiencies

if dev ne 'p' then wset,0
sstr = ['Stokes I','Stokes Q','Stokes U','Stokes V']

for ii=0,3 do begin
    plot,waves,pol_eff[ii,*],xtit='Wavelength (nm)',ytit='Modulation Efficiency',psym=4,title=sstr[ii],chars=1.2,yr=[0,1],ysty=1,xr=[500.,1100.],xsty=1
    if ii gt 0 then oplot,[0,1100],[1./sqrt(3.),1./sqrt(3.)],linesty=1

;  optionally overplot efficiencies from lab polarimeter measurements

    restore,file=$
    '/home/mgalloy/projects/UCOMP/Integration and Testing/Modulator Efficiency Validation/UCoMP Modulator 7V.sav'
    oplot,l,eff[ii,*]
endfor

if dev ne 'p' then read,'enter return',ans

for ii=0,3 do begin
    plot,waves,cal_eff[ii,*],xtit='Wavelength (nm)',ytit='Calibration Efficiency',psym=4,title=sstr[ii],chars=1.2,yr=[0,1],ysty=1
endfor

if dev ne 'p' then read,'enter return',ans

plot,waves,trans,xtit='Wavelength (nm)',tit='Calibration Optics Transmission',psym=4,ytit='Transmission',chars=1.2,yr=[0,0.5],ysty=1
plot,waves,cal_ret,xtit='Wavelength (nm)',tit='Calibration Retarder Retardation',psym=4,ytit='Retardation (deg)',chars=1.2,yr=[50,160],ysty=1
plot,waves,offset,xtit='Wavelength (nm)',tit='Retarder Offset Angle',psym=4,ytit='Angle (deg)',chars=1.2,yr=[-2.0,0.5]
plot,waves,fit_rms,xtit='Wavelength (nm)',tit='Fit Standard Deviation',psym=4,ytit='RMS (Normalized Intensity)',chars=1.2

;    save data in .sav file.  The saved variables are:
;
;     waves[ncal] - the wavelength of the calibration (nm) (one for each file analyzed on this day)
;     trans[ncal] - the calibration optics transmission
;     cal_ret[ncal] - the retardation of the calibration retarder (deg)
;     offset[ncal] - the rotational offset of the calibration reterder (deg)
;     pol_eff[4,ncal] - the polarimeter efficiency (I,Q,U,V) for each file
;     cal_eff[4,ncal]  - the calibration efficiency (I,Q,U,V) for each file
;     fit_rms[ncal] - the rms of the fit (normalized intensity units)
;     dmatrices[nmod,4,ncal] - the computed demodulaion matrices for each file
;     mod_temp[ncal] - the filtered temperature of the modulator (C)
;     u_ mod_temp[ncal] - the unfiltered temperature of the modulator (C)
;
;     to apply the calibration, Stokes = Dmatrix##Imeas

sav_file = dir+'Results.mine/'+date_str+'.sav'
save,file=sav_file,waves,trans,cal_ret,offset,pol_eff,cal_eff,fit_rms,dmatrices,mod_temp,u_mod_temp

!p.multi=0
close,1
closepost,dev
thick,1

skip_this_day:

printf,3,date_str,' Pol Cal Complete  ',systime()
close,3

end
