; docformat = 'rst'

;+
; Create dark-corrected, averaged flats for each file and put these into
; extensions of the dark-corrected master flat file. Primary header of the
; master dark-corrected flat file comes from the primary header of the first
; raw flat file of the day, while the extension header corresponding to each
; raw flat file comes from the header of the first extension of each raw flat
; file.
;
; :Params:
;   wave_region : in, required, type=string
;     wave region to find flats for
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_make_darkcor_flats, wave_region, run=run
  compile_opt strictarr

  mg_log, 'making dark-corrected flats...', name=run.logger_name, /info

  l1_dir = filepath('level1', $
                    subdir=run.date, $
                    root=run->config('processing/basedir'))

  master_flat_basename = string(run.date, wave_region, $
                                format='(%"%s.ucomp.%s.flat.fts")')
  master_flat_filename = filepath(master_flat_basename, root=l1_dir)

  master_darkcor_flat_basename = string(run.date, wave_region, $
                                        format='(%"%s.ucomp.%s.darkcor_flat.fts")')
  master_darkcor_flat_filename = filepath(master_darkcor_flat_basename, root=l1_dir)

  cal = run.calibration

  n_index_extensions = 5L
  fits_open, master_flat_filename, master_flat_fcb
  fits_open, master_darkcor_flat_filename, master_dark_cor_flat_fcb, /write

  ; need times, exposure times, and gain modes to find correct dark
  times_exten_no = master_flat_fcb.nextend - n_index_extensions + 1L
  fits_read, master_flat_fcb, times, times_header, exten_no=times_exten_no

  exptimes_exten_no = master_flat_fcb.nextend - n_index_extensions + 2L
  fits_read, master_flat_fcb, exptimes, exptimes_header, exten_no=exptimes_exten_no

  gainmodes_exten_no = master_flat_fcb.nextend - n_index_extensions + 4L
  fits_read, master_flat_fcb, gain_mode_indices, gainmodes_header, exten_no=gainmodes_exten_no

  ; read primary extension, write primary extension
  fits_read, master_flat_fcb, primary_data, primary_header, exten_no=0L
  fits_write, master_dark_cor_flat_fcb, primary_data, primary_header

  ; read flat, write dark corrected flat
  for e = 1L, master_flat_fcb.nextend - n_index_extensions do begin
    fits_read, master_flat_fcb, flat, flat_header, exten_no=e

    ; get dark for the flat
    dark = cal->get_dark(times[e - 1], $
                         exptimes[e - 1], $
                         (['low', 'high'])[gain_mode_indices[e - 1]], $
                         found=dark_found, $
                         master_extensions=master_dark_extensions, $
                         raw_filenames=raw_dark_filenames, $
                         coefficients=dark_coefficients)

    ; add RAWDARK1, DARKEXT1, RAWDARK2, DARKEXT2 to header
    after = 'RAWEXTS'
    for de = 0L, n_elements(master_dark_extensions) - 1L do begin
      ucomp_addpar, flat_header, string(de + 1, format='(%"RAWDARK%d")'), raw_dark_filenames[de], $
                    comment=string(dark_coefficients[de], $
                                   format='(%"raw dark filename used, wt %0.2f")'), $
                    after=after
      ucomp_addpar, flat_header, string(de + 1, format='(%"DARKEXT%d")'), master_dark_extensions[de], $
                    comment=string(run.date, dark_coefficients[de], $
                                   format='(%"%s.ucomp.dark.fts ext used, wt %0.2f")'), $
                    after=after
    endfor

    fits_write, master_dark_cor_flat_fcb, flat - dark, flat_header
  endfor

  ; write index arrays
  for e = master_flat_fcb.nextend - n_index_extensions + 1L, master_flat_fcb.nextend do begin
    fits_read, master_flat_fcb, index_array, index_header, exten_no=e
    fits_write, master_dark_cor_flat_fcb, index_array, index_header
  endfor

  fits_close, master_dark_cor_flat_fcb
  fits_close, master_flat_fcb
end


; main-level example program

date = '20240409'
wave_region = '789'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, 'test', config_filename)

; TODO: need to read the master dark file

ucomp_make_darkcor_flats, wave_region, run=run

obj_destroy, run

end
