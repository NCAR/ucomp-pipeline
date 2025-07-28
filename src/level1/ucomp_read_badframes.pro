; docformat = 'rst'

;+
; Read a file containing bad frames data.
;
; The new format is::
;
;   filename, polstate, camera, frame extension, filetype, reason for failure, + more info
;
; The old format was::
;
;   filename, camera, frame extension, polstate
;
; For example, for the new format::
;
;   20220331.223224.62.ucomp.1079.l0.fts, 0,1,11, sci, saturation / nonlineariy,12125

; :Returns:
;   array of structures of the form::
;
;     {filename: '', camera: 0L, extension: 0L, polstate: 0L}
;
;  `!null` if file is empty
;
; :Params:
;   filename : in, required, type=string
;     full path to file containing bad frames data
;-
function ucomp_read_badframes, filename
  compile_opt strictarr

  raw_badframes = read_csv(filename, count=n_badframes)
  if (n_badframes eq 0L) then return, !null

  badframes = replicate({filename: '', camera: 0L, extension: 0L, polstate: 0L}, n_badframes)

  ; old style bad frames files were in a different order:
  ;   filename, camera, extension, pol state
  indices = n_tags(raw_badframes) eq 4 ? indgen(4) : [0, 2, 3, 1]
  badframes.filename  = raw_badframes.(indices[0])
  badframes.camera    = raw_badframes.(indices[1])
  badframes.extension = raw_badframes.(indices[2])
  badframes.polstate  = raw_badframes.(indices[3])

  return, badframes
end
