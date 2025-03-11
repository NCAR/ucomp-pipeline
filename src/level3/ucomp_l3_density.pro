; docformat = 'rst'

pro ucomp_l3_density, run=run
  compile_opt strictarr

  ; TODO: find matching 1074 + 1079 pairs of files in the synoptic program that
  ; are within a threshold time (20 minutes?)

  ; TODO: for each set of pairs do the following:

  ; output_basename = string(strmid(f_1074[0], 0, 15), strmid(f_1079[0], 9, 6), $
  ;                          name, $
  ;                          format='%s-%s.ucomp.1074-1079.%s.density.fts')
  ; ucomp_compute_density_files, f_1074, f_1079, output_basename, $
  ;                              ignore_linewidth=ignore_linewidth, run=run
end
