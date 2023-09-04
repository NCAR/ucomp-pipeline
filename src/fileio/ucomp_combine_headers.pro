; docformat = 'rst'

;+
; Combine two extension headers into a new extension header that attempts to
; represent both headers.
;
; :Returns:
;   `strarr`
;
; :Params:
;   headers : in, required, type="strarr(n_keywords, n_ext)""
;     headers to combine
;-
function ucomp_combine_headers, headers
  compile_opt strictarr

  ; start with the first header
  header = headers[*, 0]
  n_dims = size(headers, /n_dimensions)
  dims   = size(headers, /dimensions)

  n_extensions = n_dims eq 1 ? 1 : dims[1]

  ; average the SGS values
  sgs_keywords = ['SGSSCINT', $
                  'SGSDIMV', 'SGSDIMS', $
                  'SGSSUMV', 'SGSSUMS', $
                  'SGSRAV', 'SGSRAS', $
                  'SGSDECV', 'SGSDECS', $
                  'SGSLOOP', $
                  'SGSRAZR', 'SGSDECZR']
  for k = 0L, n_elements(sgs_keywords) - 1L do begin
    values = fltarr(n_extensions)
    for e = 0L, n_extensions - 1L do begin
      values[e] = ucomp_getpar(headers[*, e], sgs_keywords[k], /float, found=found)
    endfor
    ucomp_addpar, header, sgs_keywords[k], mean(values, /nan), format='(F0.5)'
  endfor

  return, header
end
