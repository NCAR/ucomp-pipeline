; docformat = 'rst'

;+
; Average level 2 files.
;
; :Params:
;   l2_filenames : in, required, type=strarr
;     level 2 filenames
;
; :Keywords:
;   primary_header : out, optional, type=strarr
;     primary header of first level 2 file
;   peak_intensity : out, optional, type="fltarr(nx, ny)"
;     mean peak intensity
;   line_width : out, optional, type="fltarr(nx, ny)"
;     mean line width
;   date_obs : out, optional, type=string
;     earliest DATE-OBS value of the given files
;   date_end : out, optional, type=string
;     latest DATE-END value of the given files
;-
pro ucomp_average_l2_files, l2_filenames, $
                            primary_header=primary_header, $
                            peak_intensity=peak_intensity, $
                            header_peak_intensity=peak_intensity_header, $
                            line_width=line_width, $
                            header_line_width=line_width_header, $
                            date_obs=date_obs, $
                            date_end=date_end
  compile_opt strictarr

  n_files = n_elements(l2_filenames)
  for f = 0L, n_files - 1L do begin
    fits_open, l2_filenames[f], fcb

    fits_read, fcb, !null, primary_header, exten_no=0
    fits_read, fcb, file_peak_intensity, peak_intensity_header, extname='Peak intensity'
    fits_read, fcb, file_line_width, line_width_header, extname='Line width (FWHM)'

    if (f eq 0L) then begin
      dims = size(file_peak_intensity, /dimensions)
      peak_intensity = fltarr(n_files, dims[0], dims[1])
      line_width = fltarr(n_files, dims[0], dims[1])
      date_obs = strarr(n_files)
      date_end = strarr(n_files)
    endif

    peak_intensity[f, *, *] = file_peak_intensity
    line_width[f, *, *] = file_line_width
    date_obs[f] = ucomp_getpar(primary_header, 'DATE-OBS')
    date_end[f] = ucomp_getpar(primary_header, 'DATE-END')
    fits_close, fcb
  endfor

  peak_intensity = reform(mean(peak_intensity, dimension=1))
  line_width = reform(mean(line_width, dimension=1))
  date_obs = min(date_obs)
  date_end = max(date_obs)

  ; remove keywords that are not valid for averages
  keywords_to_delete = ['RAWFILE', 'FLATDN', 'CAMCORR', 'CAMDIFF', 'RCAMMED', $
                        'TCAMMED', 'SKYTRANS']
  if (n_files gt 1L) then begin
    for k = 0L, n_elements(keywords_to_delete) - 1L do begin
      ucomp_delpar, peak_intensity_header, keywords_to_delete[k]
      ucomp_delpar, line_width_header, keywords_to_delete[k]
    endfor
  endif
end
