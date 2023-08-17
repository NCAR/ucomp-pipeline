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
;   intensity : in, required, type="fltarr(1280, 1024)"
;     intensity image
;
; :Keywords:
;   radius : in, optional, type=float, default=3.0
;     `radius` argument to `UNSHARP_MASK`
;   amount : in, optional, type=float, default=2.0
;     `amount` argument to `UNSHARP_MASK`
;   occulter_radius : in, optional, type=float
;     occulter radius to use if `MASK` is set
;   post_angle : in, optional, type=float
;     post angle to use if `MASK` is set
;   field_radius : in, optional, type=float
;     field radius to use if `MASK` is set
;   mask : in, optional, type=booleam
;     set to mask the result
;
; :Author:
;   MLSO Software Team
;-
function ucomp_enhanced_intensity, intensity, $
                                   radius=radius, $
                                   amount=amount, $
                                   occulter_radius=occulter_radius, $
                                   post_angle=post_angle, $
                                   field_radius=field_radius, $
                                   mask=mask
  compile_opt strictarr

  _radius = mg_default(radius, 3.0)
  _amount = mg_default(amount, 2.0)

  if (keyword_set(mask)) then begin
    dims = size(intensity, /dimensions)
    _mask = ucomp_mask(dims[0:1], $
                       field_radius=field_radius, $
                       occulter_radius=occulter_radius + 3.5, $
                       post_angle=post_angle)
    masked_intensity = intensity * _mask
  endif else begin
    masked_intensity = intensity
  endelse

  unsharp_intensity = unsharp_mask(masked_intensity, $
                                   radius=_radius, amount=_amount)

  return, unsharp_intensity
end


; main-level example program

date = '20220901'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, 'test', config_filename)

wave_region = '1074'
processing_basedir = run->config('processing/basedir')
basename = '20220901.182014.ucomp.1074.l2.polarization.fts'
filename = filepath(basename, $
                    subdir=[run.date, 'level2'], $
                    root=processing_basedir)

fits_open, filename, fcb
fits_read, fcb, !null, primary_header, exten_no=0
fits_read, fcb, peak_intensity, peak_intensity_header, exten_no=1
fits_close, fcb

occulter_radius = ucomp_getpar(primary_header, 'RADIUS')
post_angle = ucomp_getpar(primary_header, 'POST_ANG')

enhanced_peak_intensity = ucomp_enhanced_intensity(peak_intensity, $
                                                   radius=run->line(wave_region, 'enhanced_intensity_radius'), $
                                                   amount=run->line(wave_region, 'enhanced_intensity_amount'), $
                                                   occulter_radius=occulter_radius, $
                                                   post_angle=post_angle, $
                                                   field_radius=run->epoch('field_radius'), $
                                                   mask=mask)

display_min = run->line(wave_region, 'enhanced_intensity_display_min')
display_max = run->line(wave_region, 'enhanced_intensity_display_max')
display_power = run->line(wave_region, 'enhanced_intensity_display_power')
dims = size(enhanced_peak_intensity, /dimensions)
window, xsize=dims[0], ysize=dims[1], /free, title='Enhanced peak intensity'
tv, bytscl(enhanced_peak_intensity^display_power, $
           min=display_min^display_power, $
           max=display_max^display_power)

obj_destroy, run

end
