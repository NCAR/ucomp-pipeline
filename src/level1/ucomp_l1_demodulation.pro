; docformat = 'rst'

;+
; Perform demodulation.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, required, type="fltarr(nx, ny, nexts)"
;     extension data
;   headers : in, requiredd, type=list
;     extension headers as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_demodulation, file, primary_header, data, headers, $
                           run=run, status=status
  compile_opt strictarr

  status = 0L

  ; TODO: implement
  ; file.demodulated = 1B
end
