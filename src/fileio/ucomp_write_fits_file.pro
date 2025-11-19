; docformat = 'rst'

;+
; Write a FITS file.
;
; :Params:
;   filename : in, required, type=string
;     filename to write output to
;   primary_header : in, required, type=strarr
;     FITS primary header
;   ext_data : in, required, type="fltarr(nx, ny, ..., nexts)"
;     extension data
;   ext_headers : in, required, type=list
;     list of `strarr`, each a FITS header for the corresponding extension
;   backgrounds : out, type="fltarr(nx, ny, ..., n_exts)"
;     background images
;   background_headers : in, required, type=list
;     list of `strarr`, each a FITS header for the corresponding background
;     extension
;
; :Keywords:
;   intensity : in, optional, type=boolean
;     set to extract intensity from `ext_data`
;-
pro ucomp_write_fits_file, filename, $
                           primary_header, $
                           ext_data, ext_headers, $
                           backgrounds, background_headers, $
                           intensity=intensity
  compile_opt strictarr
  on_error, 2

  n_dims = size(ext_data, /n_dimensions)
  n_background_dims = size(backgrounds, /n_dimensions)
  n_extensions = n_elements(ext_headers)

  fits_open, filename, fcb, /write
  ucomp_fits_write, fcb, 0.0, primary_header, /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  for e = 1L, n_extensions do begin
    ; define extension name
    pol_states = keyword_set(intensity) ? 'I' : 'IQUV'
    wavelength = ucomp_getpar(ext_headers[e - 1], 'WAVELNG')
    extname = string(pol_states, wavelength, format='(%"Corona Stokes %s [%0.3f nm]")')

    case n_dims of
      3: data = keyword_set(intensity) ? ext_data[*, *, 0] : ext_data
      4: data = keyword_set(intensity) ? ext_data[*, *, 0, e - 1] : ext_data[*, *, *, e - 1]
      5: data = keyword_set(intensity) ? ext_data[*, *, 0, *, e - 1] : ext_data[*, *, *, *, e - 1]
      else: begin
         dims = strjoin(strtrim(size(ext_data, /dimensions), 2), ', ')
         message, string(dims, format='(%"invalid number of dimensions to write: [%s]")')
       endelse
    endcase

    ucomp_fits_write, fcb, $
                      float(reform(data)), $
                      ext_headers[e - 1], $
                      extname=extname, /no_abort, message=error_msg
    if (error_msg ne '') then message, error_msg
  endfor

  if (~keyword_set(intensity) && n_elements(backgrounds) gt 0L) then begin
    for e = 1L, n_extensions do begin
      ; define extension name
      wavelength = ucomp_getpar(ext_headers[e - 1], 'WAVELNG')
      extname = string(wavelength, format='(%"Background IQUV [%0.3f nm]")')

      case n_background_dims of
        3: data = backgrounds
        4: data = backgrounds[*, *, *, e - 1]
        5: data = backgrounds[*, *, *, *, e - 1]
        else: begin
           dims = strjoin(strtrim(size(backgrounds, /dimensions), 2), ', ')
           message, string(dims, format='(%"invalid number of background dimensions to write: [%s]")')
         endelse
      endcase

      ucomp_fits_write, fcb, $
                        float(reform(data)), $
                        background_headers[e - 1], $
                        extname=extname, /no_abort, message=error_msg
      if (error_msg ne '') then message, error_msg
    endfor
  endif

  fits_close, fcb
end
