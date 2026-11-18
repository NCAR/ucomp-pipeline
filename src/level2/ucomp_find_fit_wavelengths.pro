; docformat = 'rst'

;+
; Find the indices of the wavelengths to use in the Gaussian fit for the given
; preferred wavelengths.
;
; :Params:
;   blue_reference_wavelength : in, required, type=float
;     blue reference wavelength [nm]
;   center_wavelength : in, required, type=float
;     center wavelength [nm]
;   red_reference_wavelength : in, required, type=float
;     red reference wavelength [nm]
;   wavelengths : in, required, type=fltarr
;     wavelengths observed [nm]
;
; :Keywords:
;   blue_index : out, optional, type=long
;     set to a named variable to retrieve the index into `wavelengths` that
;     corresponds to the wavelength to use in the Gaussian fit on the blue end
;   center_index : out, optional, type=long
;     set to a named variable to retrieve the index into `wavelengths` that
;     corresponds to the wavelength to use in the Gaussian fit in the center
;   red_index : out, optional, type=long
;     set to a named variable to retrieve the index into `wavelengths` that
;     corresponds to the wavelength to use in the Gaussian fit on the red end
;-
pro ucomp_find_fit_wavelengths, blue_reference_wavelength, $
                                center_wavelength, $
                                red_reference_wavelength, $
                                wavelengths, $
                                blue_index=blue_index, $
                                center_index=center_index, $
                                red_index=red_index
  compile_opt strictarr

  !null = min(abs(wavelengths - center_wavelength), center_index)

  tolerance = 0.001

  blue_diffs = abs(wavelengths - blue_reference_wavelength)
  blue_indices = sort(blue_diffs)
  if (abs(blue_diffs[blue_indices[0]] - blue_diffs[blue_indices[1]]) lt tolerance) then begin
    blue_index = min(blue_indices[0:1])
  endif else begin
    blue_index = blue_indices[0]
  endelse

  red_diffs = abs(wavelengths - red_reference_wavelength)
  red_indices = sort(red_diffs)
  if (abs(red_diffs[red_indices[0]] - red_diffs[red_indices[1]]) lt tolerance) then begin
    red_index = max(red_indices[0:1])
  endif else begin
    red_index = red_indices[0]
  endelse

  ; [NOTE]: this would be the simple way to do it, but it fails if there are
  ; equally spaced wavelengths on either side of the reference wavelength --
  ; blue and red both need to round to the farther from center wavelength
  ; !null = min(abs(wavelengths - blue_reference_wavelength), blue_index)
  ; !null = min(abs(wavelengths - red_reference_wavelength), red_index)
end


; main-level example program

center_wavelength = 637.4
blue_reference_wavelength = 637.350
red_reference_wavelength = 637.450
wavelengths = [637.340, 637.360, 637.380, 637.390, $
               637.400, $
               637.410, 637.420, 637.440, 637.460]

ucomp_find_fit_wavelengths, blue_reference_wavelength, $
                            center_wavelength, $
                            red_reference_wavelength, $
                            wavelengths, $
                            blue_index=blue_index, $
                            center_index=center_index, $
                            red_index=red_index

print, blue_index, wavelengths[blue_index], $
       center_index, wavelengths[center_index], $
       red_index, wavelengths[red_index], $
       format='wavelengths[%d]=%0.3f nm, wavelengths[%d]=%0.3f nm, wavelengths[%d]=%0.3f nm'

end
