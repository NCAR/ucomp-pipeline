; docformat = 'rst'

;+
; Process a UCoMP science file.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   data : in, required, type="fltarr(nx, ny, nstokes, nexts)"
;     extension data
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_create_intensity, file, data, run=run
  compile_opt strictarr

  l1_dirname = filepath('', $
                        subdir=[run.date, 'level1'], $
                        root=run->config('processing/basedir'))
  ucomp_mkdir, l1_dirname, logger_name=run.logger_name

  intensity_basename_format = string(file_basename(file.l1_basename, '.fts'), $
                                     format='(%"%s.int.ext%%02d.gif")')
  intensity_filename_format = mg_format(filepath(intensity_basename_format, $
                                                 root=l1_dirname))

  for e = 1L, file.n_extensions do begin
    im = total(reform(data[*, *, *, e - 1]), 3, /preserve_type)
    im /= (size(im, /dimensions))[-1]
    im = bytscl(im)
    write_gif, string(e, format=intensity_filename_format), im
  endfor
end
