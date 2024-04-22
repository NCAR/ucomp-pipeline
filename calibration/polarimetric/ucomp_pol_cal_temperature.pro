pro UCoMP_Pol_Cal_Temperature
;+
;    Procedure to read results of UCoMP polarimetric calibrations and correlate the results with the
;    temperature of the modulator
;
;    The results for each day are stored in an idl .sav file. The saved variables are:
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
;     u_mod_temp[ncal] - the un-filtered temperature of the modulator (C)
;
;     to apply the calibration, Stokes = Dmatrix##Imeas
;-
compile_opt strictarr

debug = 'no'       ;debug mode ('yes' or 'no')
ans = ' ' & str = ' '

dir = '/home/mgalloy/projects/UCOMP/Integration and Testing/Polarimetric Calibration/'     ;go to analysis directory
cd,dir

data_dir = '/home/mgalloy/projects/UCOMP/Integration and Testing/Polarimetric Calibration/Results.mine/'     ;results directory

;    open postscript file

openpost,dev,file='Modulator_Temperature_Dependence.ps',default='p',/no_ask        ;open ps file or output to screen
if dev eq 'p' then device,/landscape else begin
  window,0,xs=1200,ys=1000
endelse
!p.multi = [0,4,4,0,0]

;  identify .sav files to analyze

files = file_search(data_dir+'*.sav')
nfiles = n_elements(files)
print,nfiles,' sav files'

;  create arrays to hold results

; regions = [530.3,637.4,656.28,670.20,691.8,706.2,761.10,802.40,789.4,991.30,1074.7,1079.8,1083.0]    ;all wavelength regions
;regions = [637.4,706.2,761.10,802.40,789.4,991.30,1074.7,1079.8]    ;all wavelength regions
regions = [670.20, 761.10, 802.40, 991.30]    ;all wavelength regions
nreg = n_elements(regions)
med_rms = fltarr(nreg)
Dmx_coefs = fltarr(4,4,nreg,2)

for ireg=0,nreg-1 do begin          ;loop over all wavelength regions

    nmax = 400
    Dmx = fltarr(4,4,nmax)
    UTemps = fltarr(nmax)         ;unfiltered temperatures
    Temps = fltarr(nmax)            ;filtered temperatures
    rms = fltarr(nmax)

    num = 0         ;initialize number of calibrations at this wavelength counter

    for i=0,nfiles-1 do begin      ;loop over .sav files and locate all calibrations at this wavelength
      restore,file=files[i]
      good = where(waves eq regions[ireg],count)
      if count gt 0 then begin
        for j=0,count-1 do begin
          Dmx[*,*,num+j] = dmatrices[*,*,good[j]]
          Temps[num+j] = mod_temp[good[j]]
          UTemps[num+j] = u_mod_temp[good[j]]
          rms[num+j] = fit_rms[good[j]]
        endfor
        num = num+count
      endif
    endfor

    print,num,' total calibrations at ',regions[ireg]

    Dmx = Dmx[*,*,0:num-1]
    Temps = Temps[0:num-1]
    UTemps = UTemps[0:num-1]
    rms = rms[0:num-1]

    good = where(rms lt 0.02,count,complement=bad)               ;reject calibrations with poor fits
    if count gt 0 then begin
      Dmx = Dmx[*,*,good]
      Temps = Temps[good]
      UTemps = UTemps[good]
      rms = rms[good]
      num = count
    endif
    print,n_elements(bad),' cals rejected due to bad chisq'

    med_rms[ireg] = median(rms)

    nbad = 0
    all_bad = lonarr(5000)
    for jj=0,3 do for ii=0,3 do begin       ;identify outliers in data
      y = Dmx[ii,jj,*]
      dy = abs(y-median(y))
      sdy = dy[sort(dy)]
      sigma = stdev(sdy[0:0.8*n_elements(dy)])   ;compute sigma omitting the 20% worst points
      bad = where(dy gt 6.*sigma,count)             ;define bad points as those gt 4*sigma
      if count gt 0 then begin
        all_bad[nbad:nbad+count-1] = bad
        nbad = nbad+count
      endif
    endfor
    all_bad = all_bad[0:nbad-1]
    print,nbad,' points identified as outliers'
    if (nbad gt 0L) then print,all_bad

;  identify recurrent bad points defined as being bad in more than 4 Dmx elements

    h = histogram(all_bad,min=0,max=num-1)
    dont_use = where(h gt 5,count,complement=ok)
    print,n_elements(dont_use),' cals rejected due to recurrent bad points'

    chisq = fltarr(4,4)
    slope = fltarr(4,4)

    for jj=0,3 do for ii=0,3 do begin
      x = UTemps[ok]
      y = Dmx[ii,jj,ok]
      use = where(x lt 32)
      plot,x,y,psym=4,ysty=16,chars=1.5
      c = poly_fit(x[use],y[use],1,chisq=chi, status=status)
      print, ii, jj, status, format='Fit failed for Dmx[%d, %d] (POLY_FIT status %d)'
      if (status ne 0L) then continue
      Dmx_coefs[ii,jj,ireg,*] = c
      slope[ii,jj] = c[1]
      chisq[ii,jj] = chi
      xfit = findgen(35)
      yfit = poly(xfit,c)
      oplot,xfit,yfit
    endfor
    str = string(format='("D Matrix Values @",f6.1,"nm vs. Modulator Temperature (C)")',regions[ireg])
    xyouts,0.05,1.02,/norm,str,chars=2

    chisq = chisq/float(num-2)
    sig = sqrt(chisq)
    d_temp = abs(sig/slope)

;    print,'Slope'
;    for ii=0,3 do print,format='(4f12.5)',slope[*,ii]
;    print,'Noise in matrix element'
;    for ii=0,3 do print,format='(4f12.5)',sig[*,ii]
    print,'Allowable temperature variation'
    for ii=0,3 do print,format='(4f12.5)',d_temp[*,ii]

endfor
!p.multi=0
save,file='Dmx_Temp_Coefs.sav',Dmx_coefs

closepost,dev
thick,1

end
