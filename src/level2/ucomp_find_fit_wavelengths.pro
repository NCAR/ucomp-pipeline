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

  !null = min(abs(wavelengths - blue_reference_wavelength), blue_index)
  !null = min(abs(wavelengths - center_wavelength), center_index)
  !null = min(abs(wavelengths - red_reference_wavelength), red_index)
end
