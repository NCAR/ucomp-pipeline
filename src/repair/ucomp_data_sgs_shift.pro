; docformat = 'rst'

;+
; Raw data repair routine that fixes the shift of SGS values in early raw
; files
;
; For example, for 20210725.232140.72.ucomp.1074.l0.fts ext 1, the SGS keywords
; are:
;
; SGSDIMV =                4.318 / [V] SGS Dim Mean
; SGSDIMS =                6.218 / [V] SGS Dim Std
; SGSSUMV =                0.014 / [V] SGS Sum Mean
; SGSSUMS =                6.220 / [V] SGS Sum Std
; SGSRAV  =                0.005 / [V] SGS RA Mean
; SGSRAS  =               -0.000 / [V] SGS RA Std
; SGSDECV =                0.012 / [V] SGS DEC Mean
; SGSDECS =               -0.000 / [V] SGS DEC Std
; SGSLOOP =                0.013 / SGS Loop Fraction
; SGSRAZR =                1.000 / [V] SGS RA zero point
; SGSDECZR=             -157.000 / [V] SGS DEC zero point
;
; The values should be:
;
; SGSSCINT=                4.318 / [arcsec] SGS scintillation seeing estimate
; SGSDIMV =                6.218 / [V] SGS Dim Mean
; SGSDIMS =                0.014 / [V] SGS Sum Std
; SGSSUMV =                6.220 / [V] SGS Sum Mean
; SGSSUMS =                0.005 / [V] SGS Sum Std
; SGSRAV  =               -0.000 / [V] SGS RA Mean
; SGSRAS  =                0.012 / [V] SGS RA Std
; SGSDECV =               -0.000 / [V] SGS DEC Mean
; SGSDECS =                0.013 / [V] SGS DEC Std
; SGSLOOP =                1.000 / SGS Loop Fraction
; SGSRAZR =             -157.000 / [V] SGS RA zero point
; SGSDECZR=                      / [V] SGS DEC zero point
;
; Note: SGSDECZR will always be unrecorded for files in this epoch.
;
; :Params:
;   primary_header : in, out, required, type=strarr(n_keywords)
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_exts)"
;     extension data
;   ext_headers : in, out, required, type="strarr(n_keywords, n_exts)"
;     extension headers
;-
pro ucomp_data_sgs_shift, primary_header, ext_data, ext_headers
  compile_opt strictarr

  rotate_keywords = ['SGSDIMV', 'SGSDIMS', 'SGSSUMV', 'SGSSUMS', 'SGSRAV', $
                     'SGSRAS', 'SGSDECV', 'SGSDECS', 'SGSLOOP', 'SGSRAZR', $
                     'SGSDECZR']

  for e = 0L, n_elements(ext_headers) - 1L do begin
    h = ext_headers[e]

    ; create SGSSCINT
    ucomp_addpar, h, 'SGSSCINT', ucomp_getpar(h, 'SGSDIMV'), $
                  format='(F0.3)', $
                  comment='[arcsec] SGS scintillation seeing estimate', $
                  before='SGSDIMV'

    ; rotate the middle keywords up one position
    for k = 0L, n_elements(rotate_keywords) - 2L do begin
      ucomp_addpar, h, $
                    rotate_keywords[k], $
                    ucomp_getpar(h, rotate_keywords[k + 1]), $
                    format='(F0.3)'
    endfor

    ; SGSDECZR will always be unrecorded for corrected files
    ucomp_addpar, h, 'SGSDECZR', !null

    ext_headers[e] = h
  endfor
end
