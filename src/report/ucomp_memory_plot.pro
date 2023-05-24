; docformat = 'rst'

;+
; Report memory usage over run.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_memory_plot, run=run
  compile_opt strictarr

  log_basename = string(run.date, format='(%"%s.ucomp.memory.log")')
  eng_dir = filepath('', $
                     subdir=ucomp_decompose_date(run.date), $
                     root=run->config('engineering/basedir'))
  log_filename = filepath(log_basename, root=eng_dir)

  if (~file_test(log_filename, /regular)) then goto, done

  n_lines = file_lines(log_filename)
  datetimes = dblarr(n_lines)
  routines = strarr(n_lines)
  memory = ulon64arr(4, n_lines)
  line = ''
  openr, lun, log_filename, /get_lun
  for i = 0L, n_lines - 1L do begin
    readf, lun, line
    tokens = strsplit(line, 'm, ', /extract)
    dt = tokens[0]
    date_parts = long(ucomp_decompose_date(strmid(dt, 0, 8)))
    time_parts = long(ucomp_decompose_time(strmid(dt, 9, 6)))
    datetimes[i] = julday(date_parts[1], date_parts[2], date_parts[0], $
                          time_parts[0], time_parts[1], time_parts[2])
    routines[i] = tokens[1]
    memory[*, i] = ulong64(tokens[2:5])
  endfor
  free_lun, lun

  original_device = !d.name
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, set_resolution=[800, 600], $
          decomposed=0, $
          set_colors=256, $
          z_buffering=0
  loadct, 0, /silent
  tvlct, r, g, b, /get
  !p.multi = [0, 1, 2]

  charsize = 1.0
  !null = label_date(date_format='%H:%I:%S')
  plot, datetimes, memory[0, *] / 1024L / 1024L, $
        color=0, background=255, charsize=charsize, title='Current memory usage', $
        xstyle=9, xtickformat='label_date', $
        ystyle=9, ytitle='memory usage [MB]'
  plot, datetimes, memory[3, *] / 1024L / 1024L, $
        color=0, background=255, charsize=charsize, title='High water mark', $
        xstyle=9, xtickformat='label_date', $
        ystyle=9, ytitle='memory usage [MB]'

  !p.multi = 0

  output_basename = string(run.date, format='(%"%s.ucomp.memory.gif")')
  output_filename = filepath(output_basename, root=eng_dir)
  write_gif, output_filename, tvrd(), r, g, b

  done:
  if (n_elements(original_rgb) gt 0L) then  tvlct, original_rgb
  if (n_elements(original_decomposed) gt 0L) then device, decomposed=original_decomposed
  if (n_elements(original_device) gt 0L) then set_plot, original_device
end


; main-level example program

;date = '20220105'
date = '20220209'
;date = '20220214'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)
ucomp_memory_plot, run=run
obj_destroy, run

end
