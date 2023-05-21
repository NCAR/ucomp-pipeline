; docformat = 'rst'

;+
; Compute the doppler shift, and optionally the doppler velocity.
;
; :Returns:
;   doppler shift as `fltarr(nx, ny)`
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   ext_data : in, required, type="fltarr(nx, ny, n_polstates, n_wavelengths)"
;     extension date
;
; :Keywords:
;   velocity : out, optional, type="fltarr(nx, ny)"
;     set to a named variable to retrieve the doppler velocity
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_doppler, file, ext_data, velocity=velocity, run=run
  compile_opt strictarr

  velocity = !null

  n_dims = size(ext_data, /n_dimensions)
  if (n_dims ne 4L) then begin
    mg_log, 'doppler calculation requires multiple extensions', $
            name=run.logger_name, /warn
    return, !null
  endif

  dims = size(ext_data, /dimensions)
  if (dims[3] lt 3L) then begin
    mg_log, 'doppler calculation requires at least 3 extensions', $
            name=run.logger_name, /warn
    return, !null
  endif

  wavelengths = file.wavelengths

  ; TODO: this is hacked together for the current cookbook/recipes, but we need
  ; a more general solution
  center_index = dims[3] / 2
  i1 = ext_data[*, *, 0, center_index - 1]
  i2 = ext_data[*, *, 0, center_index]
  i3 = ext_data[*, *, 0, center_index + 1]
  d_lambda = wavelengths[1] - wavelengths[0]

  ucomp_analytic_gauss_fit, i1, i2, i3, d_lambda, doppler_shift=doppler

  rest_wavelength = run->line(file.wave_region, 'center_wavelength')
  doppler += rest_wavelength

  if (arg_present(velocity)) then begin
    c = 299792.458D
    velocity = (doppler - rest_wavelength) * c / rest_wavelength
  endif

  return, doppler
end
