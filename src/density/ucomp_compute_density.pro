; docformat = 'rst'

;+
; Compute the density.
;
; :Returns:
;   density image `fltarr(nx, ny)`
;
; :Params:
;   peak_intensity_1074 : in, required, type="fltarr(nx, ny)"
;     peak intensity found by Gaussian fit for 1074 nm wave region
;   peak_intensity_1079 : in, required, type="fltarr(nx, ny)"
;     peak intensity found by Gaussian fit for 1079 nm wave region
;   line_width_1074 : in, required, type="fltarr(nx, ny)"
;     line width (FWHM) found by Gaussian fit for 1074 nm wave region
;     corresponding to `peak_intensity_1074` image
;   line_width_1079 : in, required, type="fltarr(nx, ny)"
;     line width (FWHM) found by Gaussian fit for 1079 nm wave region
;     corresponding to `peak_intensity_1079` image
;   center_wavelength_1074 : in, required, type=float
;     nominal center wavelength for 1074 nm wave region
;   center_wavelength_1079 : in, required, type=float
;     nominal center wavelength for 1079 nm wave region
;   heights : in, required, type=fltarr(n_heights)
;     heights [R_sun] represented in `ratios`
;   densities : in, required, type=fltarr(n_densities)
;     densities represented in `ratios`
;   ratios : in, required, type="fltarr(n_densities, n_heights)"
;     ratios of 1074 / 1079 data
;   r_sun : in, required, type=float
;     number of pixels in 1 solar radius
;-
function ucomp_compute_density, peak_intensity_1074, peak_intensity_1079, $
                                line_width_1074, line_width_1079, $
                                center_wavelength_1074, center_wavelength_1079, $
                                heights, densities, ratios, $
                                r_sun
  compile_opt strictarr

  dims = size(peak_intensity_1074, /dimensions)
  nx = dims[0]
  ny = dims[1]

  x = rebin(reform(findgen(nx) - (nx - 1.0) / 2.0, nx, 1), nx, ny)
  y = rebin(reform(findgen(ny) - (ny - 1.0) / 2.0, 1, ny), nx, ny)
  d_pixels = sqrt(x^2 + y^2)

  ; find heights for pixels of images
  d = d_pixels / r_sun

  ; calculate ratio of 1074/1079
  ratio_1074 = peak_intensity_1074 * line_width_1074 * center_wavelength_1074
  ratio_1079 = peak_intensity_1079 * line_width_1079 * center_wavelength_1079
  ratio = ratio_1074 / ratio_1079

  ; eliminate pixels with either 1074 or 1079 below 0.0 (or some other threshold)
  mask_indices = where(peak_intensity_1074 gt 0L and peak_intensity_1079 gt 0L $
                         and finite(ratio), $
                       n_mask_indices)

  density = peak_intensity_1074 * 0.0 + !values.f_nan

  ; for each pixel of ratio:
  ;   - lookup indices of corresponding heights for pixel
  ;   - lookup indices of ratios for the ratio of the pixel, finding indices of
  ;     densities
  ;   - interpolate into densities with given indices to find density

  for index = 0L, n_mask_indices - 1L do begin
    i = mask_indices[index]
    height_location = value_locate(heights, d[i])

    ; skip pixels outside our height range, e.g., 1.0-2.0 R_sun
    if (height_location eq n_elements(heights) - 1L) then continue

    density1 = interpol(densities, $
                        reform(ratios[*, height_location]), $
                        ratio[i], $
                        /lsquadratic)
    density2 = interpol(densities, $
                        reform(ratios[*, height_location + 1]), $
                        ratio[i], $
                        /lsquadratic)

    h1 = heights[height_location]
    h2 = heights[height_location + 1]

    density[i] = (density2 - density1) / (h2 - h1) * (d[i] - h1) + density1
  endfor

  return, density
end
