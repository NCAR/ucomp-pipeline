; docformat = 'rst'

;+
; Check whether the file is missing (nearly all NaN) any wavelengths needed for
; level 2 processing.
;
; :Returns:
;   1B if missing a required wavelength
;
; :Params:
;   file : in, required, type=object
;     UCoMP file object
;   primary_header : in, required, type=strarr
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_pol_states, n_exts)"
;     extension data, removes `n_cameras` dimension on output
;   ext_headers : in, required, type=list
;     extension headers as list of `strarr`
;   backgrounds : out, type="fltarr(nx, ny, n_cameras, n_exts)"
;     background images
;   background_headers : in, required, type=list
;     extension headers of backgrounds as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_gbu_missingwavelengths, file, $
                                       primary_header, $
                                       ext_data, $
                                       ext_headers, $
                                       backgrounds, $
                                       background_headers, $
                                       run=run
  compile_opt strictarr

  ; [nm] tolerance from reference wavelength
  threshold = 0.001

  ; [pixels] fewer than this number of pixels counts as missing (even if all
  ; pixels in a raw frame are NaN, the interpolation will cause a some pixels
  ; long the edge of the frame, about 2000 per polarization state, to be
  ; non-NaN -- even if MISSING is set to NaN on the interpolation)
  n_pixels_threshold = 10000L

  ; determine center and red/blue reference wavelengths for wave region
  center_wavelength = run->line(file.wave_region, 'center_wavelength')
  blue_reference_wavelength = run->line(file.wave_region, 'blue_reference_wavelength')
  red_reference_wavelength = run->line(file.wave_region, 'red_reference_wavelength')

  ; see if the file has those wavelengths
  wavelengths = file.wavelengths
  center_indices = where(abs(wavelengths eq center_wavelength) lt threshold, n_center)
  blue_indices = where(abs(wavelengths eq blue_reference_wavelength) lt threshold, n_blue)
  red_indices = where(abs(wavelengths eq red_reference_wavelength) lt threshold, n_red)

  center_missing = 0B
  for w = 0L, n_center - 1L do begin
    n_good_pixels = total(finite(ext_data[*, *, *, center_indices[w]]) gt 0L, /integer)
    if (n_good_pixels lt n_pixels_threshold) then begin
      center_missing = 1B
    endif
    mg_log, '%d good pixels for %0.2f nm', n_good_pixels, center_wavelength, $
            name=run.logger_name, /debug
  endfor

  blue_missing = 0B
  for w = 0L, n_blue - 1L do begin
    n_good_pixels = total(finite(ext_data[*, *, *, blue_indices[w]]) gt 0L, /integer)
    if (n_good_pixels lt n_pixels_threshold) then begin
      blue_missing = 1B
    endif
    mg_log, '%d good pixels for %0.2f nm', n_good_pixels, blue_reference_wavelength, $
            name=run.logger_name, /debug
  endfor

  red_missing = 0B
  for w = 0L, n_blue - 1L do begin
    n_good_pixels = total(finite(ext_data[*, *, *, red_indices[w]]) gt 0L, /integer)
    if (n_good_pixels lt n_pixels_threshold) then begin
      red_missing = 1B
    endif
    mg_log, '%d good pixels for %0.2f nm', n_good_pixels, red_reference_wavelength, $
            name=run.logger_name, /debug
  endfor

  return, center_missing || blue_missing || red_missing
 end
