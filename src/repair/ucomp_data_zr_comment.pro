; docformat = 'rst'

;+
; Change the `SGSRAZR` and `SGSDECZR` comments to be "[arcsec]" units, i.e.::
;
;     SGSRAZR =            -21.40000 / [V] SGS RA zero point
;     SGSDECZR=             50.50000 / [V] SGS DEC zero point
;
; to::
;
;     SGSRAZR =            -21.40000 / [arcsec] SGS RA zero point
;     SGSDECZR=             50.50000 / [arcsec] SGS DEC zero point
;
; :Params:
;   primary_header : in, out, required, type=strarr(n_keywords)
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_exts)"
;     extension data
;   ext_headers : in, out, required, type="strarr(n_keywords, n_exts)"
;     extension headers
;-
pro ucomp_data_zr_comment, primary_header, ext_data, ext_headers
  compile_opt strictarr

  n_extensions = n_elements(ext_headers)
  for e = 0L, n_extensions - 1L do begin
    h = ext_headers[e]

    sgsrazr = ucomp_getpar(h, 'SGSRAZR', /float, found=razr_found)
    sgsdeczr = ucomp_getpar(h, 'SGSDECZR', /float, found=deczr_found)

    if (razr_found) then begin
      ucomp_addpar, h, 'SGSRAZR', sgsrazr, comment='[arcsec] SGS RA zero point'
    endif
    if (deczr_found) then begin
      ucomp_addpar, h, 'SGSDECZR', sgsdeczr, comment='[arcsec] SGS DEC zero point'
    endif

    ext_headers[e] = h
  endfor
end
