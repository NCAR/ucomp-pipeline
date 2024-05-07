; docformat = 'rst'

;+
; Find the indices of the wavelengths to use in the Gaussian fit for the given
; wavelength, center wavelength, and offset from the center for the preferred
; wing wavelengths.
;
; :Params:
;   center_wavelength : in, required, type=float
;     center wavelength [nm]
;   wing_offset : in, required, type=float
;     offset from `center_wavelength` to the preferred wing wavelengths [nm]
;   wavelengths : in, required, type=fltarr
;     wavelengths observed [nm]
;
; :Keywords:
;   blue_index : out, optional, type=long
;     set to a named variable to retrieve the index into `wavelengths` that
;     corresponds to the wavelength to use in the Gaussian fit on the blue end
;   center_index : out, optional, type=long
;   red_index : out, optional, type=long
;     set to a named variable to retrieve the index into `wavelengths` that
;     corresponds to the wavelength to use in the Gaussian fit on the red end
;-
pro ucomp_find_fit_wavelengths, center_wavelength, $
                                wing_offset, $
                                wavelengths, $
                                blue_index=blue_index, $
                                center_index=center_index, $
                                red_index=red_index
  compile_opt strictarr

  !null = min(abs(wavelengths - (center_wavelength - wing_offset)), blue_index)
  !null = min(abs(wavelengths - center_wavelength), center_index)
  !null = min(abs(wavelengths - (center_wavelength + wing_offset)), red_index)
end
