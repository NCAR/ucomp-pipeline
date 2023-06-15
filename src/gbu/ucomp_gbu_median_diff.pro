; docformat = 'rst'

;+
; Check whether the difference of the image from the median value is above the
; threshold.
;
; :Returns:
;   1B if the difference is too high
;
; :Params:
;   file : in, required, type=object
;     UCoMP file object
;   primary_header : in, required, type=strarr
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_pol_states, n_exts)"
;     extension data, removes `n_cameras` dimension on output
;   ext_headers : in, required, type=list
;     extension headers as list of `strarr`
;   backgrounds : out, type="fltarr(nx, ny, n_cameras, n_exts)"
;     background images
;   background_headers : in, required, type=list
;     extension headers of backgrounds as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_gbu_median_diff, file, $
                                primary_header, $
                                ext_data, $
                                ext_headers, $
                                backgrounds, $
                                background_headers, $
                                run=run
  compile_opt strictarr

  ; TODO: remove when implemented
  return, 0UL

  n_stokes = 4L
  sigma = fltarr(file.n_extensions, n_stokes)

  dt = string(file.ut_date, file.ut_time, format='%s.%s')
  max_stddev = run->line(file.wave_region, 'gbu_max_stddev', datetime=dt)

  data_median = median(ext_data[*, *, *, *], dimension=4,/even)
  data_mean = mean(ext_data[*, *, *, *], dimension=4)

  for e = 0L, file.n_extensions - 1L do begin
    for p = 0L, n_stokes - 1L do begin
    endfor
  endfor

  return, file.median_background gt max_background
end

;         sumsq = dblarr(nx,ny,nwave,nstokes)
;         for i=0,nuse-1 do sumsq = sumsq+IQUV[*,*,*,*,use_files[i]]^2
;         all_sigma = sqrt(sumsq/double(nuse)-data_mean^2)       ;sigma at each pixel, wavelength and\
;  stokes computed over files
;
; for j=0,nwave-1 do begin
;     for k=0,nstokes-1 do begin
;         zer = where(all_sigma[*,*,j,k] eq 0. or mask eq 0.,complement=noz)
;         diff = abs(IQUV[*,*,j,k,i] - data_median[*,*,j,k])/all_sigma[*,*,j,k]
;         sigma[j,k] = median(diff[noz])
;       endfor
;     endfor
; sigma = sigma < 999.
;
;  if max(sigma) gt sig_limit[ifilt] then good_file[i] = good_file[i] + 64
