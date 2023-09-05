; docformat = 'rst'

;+
; Correct for ratio of sky transmission between science and flat image.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, required, type="fltarr(nx, ny, n_pol_states, nexts)"
;     extension data
;   headers : in, required, type=list
;     extension headers as list of `strarr`
;   backgrounds : out, type="fltarr(nx, ny, n_exts)"
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
pro ucomp_l1_sky_transmission, file, $
                               primary_header, $
                               data, headers, $
                               backgrounds, background_headers, $
                               run=run, status=status
  compile_opt strictarr

  status = 0L

  for e = 0L, n_elements(headers) - 1L do begin
    h = headers[e]
    background_h = background_headers[e]

    ; retrieve SKYTRANS, which temporarily has flat_sgsdimv in it
    flat_sgsdimv = ucomp_getpar(h, 'SKYTRANS')
    sci_sgsdimv = ucomp_getpar(h, 'SGSDIMV')

    ; TODO: correct SGSDIMV readings for wavelength

    sky_transmission = flat_sgsdimv / sci_sgsdimv
    data[*, *, *, e]  *= sky_transmission
    backgrounds[*, *, e]  *= sky_transmission

    ucomp_addpar, h, 'SKYTRANS', sky_transmission, format='(F0.3)'
    ucomp_addpar, background_h, 'SKYTRANS', sky_transmission, format='(F0.3)'

    headers[e] = h
    background_headers[e] = background_h
  endfor


end
