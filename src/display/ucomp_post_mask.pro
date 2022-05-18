; docformat = 'rst'

;+
; Create mask of post.
;
; :Returns:
;   `bytarr(nx, ny)`
;
; :Params:
;   nx : in, required, type=long
;     width of image
;   ny : in, required, type=long
;     height of image
;   post_angle : in, required, type=float
;     position angle of post
;
; :Keywords:
;   post_width : in, optional, type=float, default=60.0
;     width of the post in pixels
;-
function ucomp_post_mask, nx, ny, post_angle, post_width=post_width
  compile_opt strictarr

  _post_width = mg_default(post_width, 60.0)

  post_mask = fltarr(nx,ny) + 1.0

  x = rebin(indgen(nx) - nx / 2.0, nx, ny)
  y = transpose(rebin(indgen(ny) - ny / 2.0, ny, nx))

  ; mask out occulter post (to south)
  post_mask[where(abs(x) lt _post_width / 2.0 and y lt 0.0)] = 0.0

  ; mask out occulter post (to north)
  ; post_mask[where(abs(x) lt _post_width / 2.0 and y gt 0.0)] = 0.0

  ; mask out occulter post at angle 0
  ; post_mask[where(abs(y) lt _post_width / 2.0 and x gt 0.0)] = 0.0

  ; negate because positive rot is clockwise, opposite of position angle
  post_mask = rot(post_mask, 180.0 - post_angle, /interp)
  
  ; remask where rotate made values between 0 and 1
  bad_indices = where(post_mask gt 0.0 and post_mask lt 1.0, n_bad)
  if (n_bad gt 0L) then post_mask[bad_indices] = 1.0

  return, byte(post_mask)
end
