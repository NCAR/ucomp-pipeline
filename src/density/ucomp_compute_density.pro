; docformat = 'rst'

function ucomp_compute_density, peak_intensity_1074, peak_intensity_1079, $
                                line_width_1074, line_width_1079, $
                                center_wavelength_1074, center_wavelength_1079, $
                                heights, densities, ratios, r_sun
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

    density_location = value_locate(ratios[*, height_location], ratio[i])

    ; skip pixels outside our density range
    if (density_location eq n_elements(densities) - 1L) then continue

    r1 = ratios[density_location, height_location]
    r2 = ratios[density_location + 1, height_location + 1]
    d1 = densities[density_location]
    d2 = densities[density_location + 1]

    density[i] = d1 + (d2 - d1) * (ratio[i] - r1) / (r2 - r1)

    ; c = randomu(seed, 1)
    ; if (c[0] lt 0.0001) then begin
    ;   height_range = string(heights[height_location], heights[height_location + 1], $
    ;                         format='%0.3f-%0.3f')
    ;   print, i, array_indices(d, i), d_pixels[i], d[i], height_range, ratio_1074[i], ratio_1079[i], ratio[i], $
    ;          density_location, $
    ;          format='%d: d[%d, %d], %0.2f, %0.3f, %s, %0.3f, %0.3f, %0.3f, %d'
    ;   print, ratios[density_location: density_location + 1, height_location:height_location + 1]
    ;   print, densities[density_location], densities[density_location + 1]
    ;   print, d1, d2, density[i]
    ; endif
  endfor

  return, density
end
