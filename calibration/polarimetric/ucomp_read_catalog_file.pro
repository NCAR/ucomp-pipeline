pro UCoMP_Read_Catalog_File,date_str,files,num_exts,num_sums,type,exposures,gains,wave_regions,num_waves,times
;+
;  procedure to read UCoMP catalog file and return information
;
;   input:
;       date_str - string of date to read (yyyymmdd)
;
;   output:
;       files - array with filenames (string)
;       num_exts - array with number of extensions (integer)
;       num_sums - array with number of sums (integer)
;       type - array with data type (dark, flat, sci, cal, etc.) (string)
;       exposures - array of exposure times (float)
;       gains - array of gain mode (string)
;       wave_region - array of wavelength region (integer)
;       num_waves - array of number of wavelengths (integer)
;       times - UT from filename (float). If next UT day, 24 hours are added.
;-
data_dir = '/hao/dawn/Data/UCoMP/process.steve/'+date_str
file = data_dir+'/'+date_str+'.ucomp.catalog.txt'
print,file

nmax = 1000
files = strarr(nmax)
num_exts= intarr(nmax)
num_sums = intarr(nmax)
type = strarr(nmax)
exposures = fltarr(nmax)
gains = strarr(nmax)
wave_regions = intarr(nmax)
num_waves = intarr(nmax)

i = 0

openr,4,file,error=err
if err ne 0 then begin
    print,'error opening catalog file for: ',date_str
    goto,jumpout
endif

f = ' ' & t = ' '  & g = ' '
while not eof(4) do begin
    readf,4,format='(a38,i5,5x,i4,1x,a5,1x,f7.2,3x,a4,2x,i4,3x,i3)',f,e,n,t,ex,g,w,nw
    files[i] = strcompress(f,/remove_all)
    num_exts[i] = fix(e)
    num_sums[i] = fix(n)
    type[i] =  strcompress(t,/remove_all)
    exposures[i] = float(ex)
    gains[i] = strcompress(g,/remove_all)
    wave_regions[i] = fix(w)
    num_waves[i] = fix(nw)

    i = i+1
endwhile
close,4

files = files[0:i-1]
num_exts = num_exts[0:i-1]
num_sums = num_sums[0:i-1]
type = type[0:i-1]
exposures = exposures[0:i-1]
gains = gains[0:i-1]
wave_regions = wave_regions[0:i-1]
num_waves = num_waves[0:i-1]

;  compute time from filename (fractional hours) add 24 hours if next UT day

nfiles = i
times = fltarr(nfiles)
for i=0,nfiles-1 do begin
    date = strmid(files[i],0,8)
    time = strmid(files[i],9,6)

    day = fix(strmid(date,6,2))
    month = fix(strmid(date,4,2))
    year = fix(strmid(date,0,4))

    hh = fix(strmid(time,0,2))
    if hh lt 10 then hh=hh+24
    mm = fix(strmid(time,2,2))
    ss = fix(strmid(time,4,2))

    times[i] = float(hh)+float(mm)/60.+float(ss)/3600.
endfor

jumpout:
end
