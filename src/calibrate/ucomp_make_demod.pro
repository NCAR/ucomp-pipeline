; docformat = 'rst'

;+
; Find the demodulation matrix and write the cal files for each wave region.
;
; :Params:
;   wave_region : in, required, type=string
;     wave region to find flats for
;
; :Keywords:
;   run : in, required, type=object
;     KCor run object
;-
pro ucomp_make_demod, wave_region, run=run
  compile_opt strictarr

  mg_log, 'making demod matrix for %s nm...', wave_region, $
          name=run.logger_name, /info

  l1_dir = filepath('level1', $
                    subdir=run.date, $
                    root=run->config('processing/basedir'))
  ucomp_mkdir, l1_dir, logger_name=run.logger_name

  ; TODO: implement, i.e., call into Steve's code

  output_basename = string(run.date, wave_region, $
                           format='(%"%s.ucomp.demod.%s.fts")')
  output_filename = filepath(output_basename, root=l1_dir)

  done:
end
