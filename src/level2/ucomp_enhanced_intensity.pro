; docformat = 'rst'

;+
; Return an enhanced intensity image.
;
; :Uses:
;   sxpar, mpfitfun
;
; :Returns:
;   enhanced intensity image, `bytarr(1280, 1024)`
;
; :Params:
;   data : in, required, type="fltarr(1280, 1024)"
;     image
;   header : in, required, type=strarr
;     FITS header with geometry information
;
; :Keywords:
;   status : out, optional, type=integer
;     set to a named variable to retrieve `MPFITFUN` status, <= 0 indicates
;     definite error
;   error_msg : out, optional, type=string
;     set to named variable to retrieve `MPFITFUN` error message, empty string
;     if no error
;
; :Author:
;   MLSO Software Team
;-
function ucomp_enhanced_intensity, data, header, r_outer, $
                                   status=status, $
                                   error_msg=error_msg
  compile_opt strictarr

  r_inner = ucomp_getpar(header, 'RADIUS')
  xycenter = [sxpar(hdr, 'CRPIX1'), sxpar(hdr, 'CRPIX2')] - 1.0

  dims = size(data, /dimensions)
  v_x = dindgen(dims[0])
  v_y = dindgen(dims[1])
  x   = rebin(v_x, dims[0], dims[1]) - xycenter[0]
  y   = rebin(transpose(v_y), dims[0], dims[1]) - xycenter[1]
  r   = sqrt(x^2 + y^2)

  sort_indices = sort(r)
  sorted_r  = r[sort_indices]
  sorted_im = data[sort_indices]

  minp = min(where(sorted_r ge r_inner))
  maxp = max(where(sorted_r le r_outer))
  lx1 = sorted_r[minp:maxp]
  ly1 = sorted_im[minp:maxp]
  err = 1.0D
  start = [1.0D6, 50.0D]

  lfit = mpfitfun('ucomp_expfit', lx1, ly1, err, start, /nan, /quiet, $
                  errmsg=error_msg, status=status)
  limb = bytscl(data / ucomp_expfit(r, lfit), min=0, max=4)
  mlimb = unsharp_mask(limb, amount=5)

  fitim = mlimb * (r ge r_inner - 1.0)

  return, fitim
end
