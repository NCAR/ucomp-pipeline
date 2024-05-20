; docformat = 'rst'

;+
; Find all the files of a given type in the processing directories.
;
; :Returns:
;   `strarr` of filenames, or `!null` if none found
;
; :Params:
;   type : in, required, type=string
;     type of file to find, 'l1', 'dynamics', etc.
;
; :Keywords:
;   wave_region : in, optional, type=string
;     wave region to search for, if needed by `type`
;   count : out, optional, type=integer
;     set to a named variable to retrieve the number of filenames returned
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_find_files, type, wave_region=wave_region, count=count, run=run
  compile_opt strictarr

  processing_basedir = filepath('', $
                                subdir=run.date, $
                                root=run->config('processing/basedir'))
  switch type of
    'level1':
    'l1': begin
        base_glob = string(wave_region, format='*.*.ucomp.%s.l1.{[0-9],[0-9][0-9]}.fts')
        glob = filepath(base_glob, $
                        subdir='level1', $
                        root=processing_basedir)
        break
      end
    'dynamics': begin
        base_glob = string(wave_region, format='*.*.ucomp.%s.l2.dynamics.fts')
        glob = filepath(base_glob, $
                        subdir='level2', $
                        root=processing_basedir)
        break
      end
    'polarization': begin
        base_glob = string(wave_region, format='*.*.ucomp.%s.l2.polarization.fts')
        glob = filepath(base_glob, $
                        subdir='level2', $
                        root=processing_basedir)
        break
      end
    'mean': begin
        base_glob = string(wave_region, format='*.ucomp.%s.l2.*.mean.fts')
        glob = filepath(base_glob, $
                        subdir='level2', $
                        root=processing_basedir)
        break
      end
    'median': begin
        base_glob = string(wave_region, format='*.ucomp.%s.l2.*.median.fts')
        glob = filepath(base_glob, $
                        subdir='level2', $
                        root=processing_basedir)
        break
      end
    'sigma': begin
        base_glob = string(wave_region, format='*.ucomp.%s.l2.*.sigma.fts')
        glob = filepath(base_glob, $
                        subdir='level2', $
                        root=processing_basedir)
        break
      end
    'quick_invert': begin
        base_glob = string(wave_region, format='*.ucomp.%s.l2.*.{mean,median}.quick_invert.fts')
        glob = filepath(base_glob, $
                        subdir='level2', $
                        root=processing_basedir)
        break
      end
    else:
  endswitch

  files = file_search(glob, count=count)
  if (count eq 0L) then files = !null
  return, files
end
