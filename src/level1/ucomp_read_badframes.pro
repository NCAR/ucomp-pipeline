; docformat = 'rst'

;+
; Read a file containing bad frames data.
;
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
  badframes.filename  = raw_badframes.(0)
  badframes.camera    = raw_badframes.(1)
  badframes.extension = raw_badframes.(2)
  badframes.polstate  = raw_badframes.(3)

  return, badframes
end

; main-level example program
date = '20220310'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

badframes = run.badframes

obj_destroy, run

end
