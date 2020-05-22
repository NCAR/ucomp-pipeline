; docformat = 'rst'

;+
; Apply the dark and gain.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, required, type="fltarr(nx, nx, nexts)"
;     extension data
;   headers : in, requiredd, type=list
;     extension headers as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_apply_dark_gain, file, primary_header, data, headers, run=run
  compile_opt strictarr

  ; TODO: implement

  ; TODO: for each extension in file
  dark = run->get_dark(time, exptime, gain_mode, found=found)
  flat = run->get_flat(time, exptime, gain_mode, pol_state, wavelength, found=found)
  ; TODO: need to broadcast dark to correction size
  im = (im - dark) / (im - flat)
  im *= gain_transmission

  ; TODO: send back to file
end
