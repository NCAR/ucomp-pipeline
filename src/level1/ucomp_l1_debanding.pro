; docformat = 'rst'

;+
; Remove the striping on the Q, U, and V images.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, out, required, type="fltarr(nx, ny, n_pol_states, n_cameras, nexts)"
;     extension data
;   headers : in, required, type=list
;     extension headers as list of `strarr`
;   backgrounds : out, type="fltarr(nx, ny, n_pol_states, n_cameras, n_exts)"
;     background images
;   background_headers : in, required, type=list
;     extension headers for background images as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_debanding, file, $
                        primary_header, $
                        data, headers, $
                        backgrounds, background_headers, $
                        run=run, status=status
  compile_opt strictarr

  status = 0L

  dims = size(data, /dimensions)
  n_columns    = dims[0]
  n_rows       = dims[1]
  n_polstates  = dims[2]
  n_cameras    = dims[3]
  n_extensions = n_elements(headers)

  threshold = run->line(file.wave_region, 'debanding_threshold')
  center_wavelength_extension = file.n_unique_wavelengths / 2L

  ; vertical debanding
  for c = 0L, n_cameras - 1L do begin
    for p = 1L, n_polstates - 1L do begin
      for e = 0L, n_extensions - 1L do begin
        for col = 0L, n_columns - 1L do begin
          band = data[col, *, p, c, e]
          center_intensity = data[col, *, 0, c, center_wavelength_extension]
          center_polarization = data[col, *, p, c, center_wavelength_extension]
          low_indices = where(center_intensity lt threshold $
                                and abs(center_polarization) lt threshold, $
                              n_low)
          stripe_offset = (n_low gt 5L) ? median(band[low_indices]) : 0.0
          data[col, *, p, c, e] -= stripe_offset
        endfor
      endfor
    endfor
  endfor

  ; horizontal debanding
  if (file.gain_mode eq 'low') then begin
    for c = 0L, n_cameras - 1L do begin
      for p = 1L, n_polstates - 1L do begin
        for e = 0L, n_extensions - 1L do begin
          for row = 0L, n_rows - 1L do begin
            band = data[*, row, p, c, e]
            center_intensity = data[*, row, 0, c, center_wavelength_extension]
            center_polarization = data[*, row, p, c, center_wavelength_extension]
            low_indices = where(center_intensity lt threshold $
                                  and abs(center_polarization) lt threshold, $
                                n_low)
            stripe_offset = (n_low gt 5L) ? median(band[low_indices]) : 0.0
            data[*, row, p, c, e] -= stripe_offset
          endfor
        endfor
      endfor
    endfor
  endif
end
