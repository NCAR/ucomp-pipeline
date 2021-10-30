; docformat = 'rst'

;+
; Produce SGS plots.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_sgs_plots, engineering_dir, run=run
  compile_opt strictarr

  files = run->get_files(count=n_files)
  if (n_files eq 0L) then begin
    mg_log, 'no raw files to plot, skipping', name=run.logger_name, /info
    goto, done
  endif else begin
    mg_log, 'plotting %d raw files', n_files, name=run.logger_name, /info
  endelse

  hours     = fltarr(n_files)

  sgs_dimv  = fltarr(n_files)
  sgs_dims  = fltarr(n_files)
  sgs_scint = fltarr(n_files)
  sgs_sumv  = fltarr(n_files)
  sgs_sums  = fltarr(n_files)
  sgs_loop  = fltarr(n_files)
  sgs_rav   = fltarr(n_files)
  sgs_ras   = fltarr(n_files)
  sgs_razr  = fltarr(n_files)
  sgs_decv  = fltarr(n_files)
  sgs_decs  = fltarr(n_files)
  sgs_deczr = fltarr(n_files)

  for f = 0L, n_files - 1L do begin
    hours[f]     = files[f].obsday_hours + 10.0

    sgs_dimv[f]  = files[f].sgs_dimv[0]
    sgs_dims[f]  = files[f].sgs_dims[0]
    sgs_scint[f] = files[f].sgs_scint[0]
    sgs_sumv[f]  = files[f].sgs_sumv[0]
    sgs_sums[f]  = files[f].sgs_sums[0]
    sgs_loop[f]  = files[f].sgs_loop[0]
    sgs_rav[f]   = files[f].sgs_rav[0]
    sgs_ras[f]   = files[f].sgs_ras[0]
    sgs_razr[f]  = files[f].sgs_razr[0]
    sgs_decv[f]  = files[f].sgs_decv[0]
    sgs_decs[f]  = files[f].sgs_decs[0]
    sgs_deczr[f] = files[f].sgs_deczr[0]
  endfor

  sorted_indices = sort(hours)

  hours = hours[sorted_indices]

  sgs_dimv  = sgs_dimv[sorted_indices]
  sgs_dims  = sgs_dims[sorted_indices]
  sgs_scint = sgs_scint[sorted_indices]
  sgs_sumv  = sgs_sumv[sorted_indices]
  sgs_sums  = sgs_sums[sorted_indices]
  sgs_loop  = sgs_loop[sorted_indices]
  sgs_rav   = sgs_rav[sorted_indices]
  sgs_ras   = sgs_ras[sorted_indices]
  sgs_razr  = sgs_razr[sorted_indices]
  sgs_decv  = sgs_decv[sorted_indices]
  sgs_decs  = sgs_decs[sorted_indices]
  sgs_deczr = sgs_deczr[sorted_indices]

  pdate = string(ucomp_decompose_date(run.date), format='(%"%s-%s-%s")')
  time_range = [16.0, 28.0]

  ; set up graphics window & color table for sgs.eng.gif
  original_device = !d.name
  set_plot, 'Z'
  device, set_resolution=[772, 1000], $
          decomposed=0, $
          set_colors=256, $
          z_buffering=0

  charsize = 0.5

  n_plots = 3
  !p.multi = [0, 1, n_plots]

  mg_range_plot, hours, sgs_dimv, $
                 title=pdate + ' UCoMP Spar Guider System (SGS) DIMV Relative Sky Transmission Mean Signal', $
                 xtitle='Hours [UT]', ytitle='SGS DIMV Relative Sky Transmission [volts]', $
                 xrange=time_range, $
                 /ynozero, ystyle=1, yrange=run->epoch('sgsdimv_range'), $
                 background=255, color=0, charsize=n_plots * charsize, $
                 clip_thick=2.0, psym=1

  mg_range_plot, hours, sgs_dims, $
                 title=pdate + ' UCoMP Spar Guider System (SGS) DIMS Relative Sky Transmission Std Deviation', $
                 xtitle='Hours [UT]', ytitle='SGS DIMS Relative Sky Transmission Std Deviation [volts]', $
                 xrange=time_range, $
                 /ynozero, ystyle=1, yrange=run->epoch('sgsdims_range'), $
                 background=255, color=0, charsize=n_plots * charsize, $
                 clip_thick=2.0, psym=1

  mg_range_plot, hours, sgs_scint, $
                 title=pdate + ' UCoMP Spar Guider System (SGS) Scintillation (Atmospheric Seeing) Estimate', $
                 xtitle='Hours [UT]', ytitle='SGS Scintillation (Seeing) Est. [arcsec]', $
                 xrange=time_range, $
                 ystyle=1, yrange=run->epoch('sgsscint_range'), $
                 background=255, color=0, charsize=n_plots * charsize, $
                 clip_thick=2.0

  sgs_seeing_gif_filename = filepath(run.date + '.ucomp.sgs.sky_transmission_and_seeing.gif', $
                                     root=engineering_dir)
  mg_log, 'SGS seeing GIF: %s', file_basename(sgs_seeing_gif_filename), $
          name=run.logger_name, $
          /debug
  write_gif, sgs_seeing_gif_filename, tvrd()

  n_plots = 3
  !p.multi = [0, 1,  n_plots]

  mg_range_plot, hours, sgs_sumv, $
                 title=pdate + ' UCoMP Spar Guider System (SGS) SUMV Mean Sum Signal (Low Pass Filter of DIMV)', $
                 xtitle='Hours [UT]', ytitle='SGS Mean Sum Signal [volts]', $
                 xrange=time_range, $
                 /ynozero, ystyle=1, yrange=run->epoch('sgssumv_range'), $
                 background=255, color=0, charsize=n_plots * charsize, $
                 clip_thick=2.0, psym=1

  mg_range_plot, hours, sgs_sums, $
                 title=pdate + ' UCoMP Spar Guider System (SGS) SUMS Sum Signal Std. Deviation (Low Pass Filter of DIMS)', $
                 xtitle='Hours [UT]', ytitle='SGS Sum Signal Std Deviation [Volts]', $
                 xrange=time_range, $
                 /ynozero, ystyle=1, yrange=run->epoch('sgssums_range'), $
                 background=255, color=0, charsize=n_plots * charsize, $
                 clip_thick=2.0, psym=1

  mg_range_plot, hours, sgs_loop, $
                 title=pdate + ' UCoMP Spar Guider System (SGS) LOOP: Closed Loop Fraction 1=solar tracking, 0=drift', $
                 xtitle='Hours [UT]', ytitle='SGS Closed Loop Fraction: 1 = solar tracking 0=drift', $
                 xrange=time_range, $
                 /ynozero, ystyle=1, yrange=run->epoch('sgsloop_range'), $
                 background=255, color=0, charsize=n_plots * charsize, $
                 clip_thick=2.0, psym=1

  sgs_signal_gif_filename  = filepath(run.date + '.ucomp.sgs.signal.gif', $
                                      root=engineering_dir)
  mg_log, 'SGS signal GIF: %s', file_basename(sgs_signal_gif_filename), $
          name=run.logger_name, $
          /debug
  write_gif, sgs_signal_gif_filename, tvrd()

  n_plots = 3
  !p.multi = [0, 1, n_plots]

  ; use daily min/max as range for SGSDECZR, unless all 0.0s
  sgsrazr_range = [min(sgs_razr, max=sgs_razr_max), sgs_razr_max]
  sgsrazr_range += 0.1 * ((sgsrazr_range[1] - sgsrazr_range[0]) > 1.0) * [-1.0, 1.0]

  mg_range_plot, hours, sgs_rav, $
                 title=pdate + ' UCoMP Spar Guider System (SGS) RAV Right Ascension Error Signal', $
                 xtitle='Hours [UT]', ytitle='SGS RA Error Signal [volts]', $
                 xrange=time_range, $
                 /ynozero, ystyle=1, yrange=run->epoch('sgsrav_range'), $
                 background=255, color=0, charsize=n_plots * charsize, $
                 clip_thick=2.0, psym=1

  mg_range_plot, hours, sgs_ras, $
                 title=pdate + ' UCoMP Spar Guider System (SGS) RAS Right Ascension Std Deviation', $
                 xtitle='Hours [UT]', ytitle='SGS RA Error Signal Std Dev [volts]', $
                 xrange=time_range, $
                 /ynozero, ystyle=1, yrange=run->epoch('sgsras_range'), $
                 background=255, color=0, charsize=1.0, $
                 clip_thick=2.0, psym=1
  
  mg_range_plot, hours, sgs_razr, $
                 title=pdate + ' UCoMP Spar Guider System (SGS) RAZR Right Ascension Zero Point Offset', $
                 xtitle='Hours [UT]', ytitle='SGS RAZR Zero Point Offset [arcsec]', $
                 xrange=time_range, $
                 ystyle=1, yrange=sgsrazr_range, $
                 background=255, color=0, charsize=n_plots * charsize, $
                 clip_thick=2.0

  sgs_ra_gif_filename  = filepath(run.date + '.ucomp.sgs.ra.gif', $
                                  root=engineering_dir)
  mg_log, 'SGS RA GIF: %s', file_basename(sgs_ra_gif_filename), $
          name=run.logger_name, $
          /debug
  write_gif, sgs_ra_gif_filename, tvrd()

  n_plots = 3
  !p.multi = [0, 1, n_plots]

  ; use daily min/max as range for SGSDECZR, unless all 0.0s
  sgsdeczr_range = [min(sgs_deczr, max=sgs_deczr_max), sgs_deczr_max]
  sgsdeczr_range += 0.1 * ((sgsdeczr_range[1] - sgsdeczr_range[0]) > 1.0) * [-1.0, 1.0]

  mg_range_plot, hours, sgs_decv, $
                 title=pdate + ' UCoMP DECV: Spar Guider System (SGS) Declination Error Signal', $
                 xtitle='Hours [UT]', ytitle='SGS DEC Error Signal [volts]', $
                 xrange=time_range, $
                 /ynozero, ystyle=1, yrange=run->epoch('sgsdecv_range'), $
                 background=255, color=0, charsize=n_plots * charsize, $
                 clip_thick=2.0, psym=1

  mg_range_plot, hours, sgs_decs, $
                 title=pdate + ' UCoMP DECS: Spar Guider System (SGS) Declination Std Deviation', $
                 xtitle='Hours [UT]', ytitle='SGS DEC Error Signal Std Dev [volts]', $
                 xrange=time_range, $
                 /ynozero, ystyle=1, yrange=run->epoch('sgsdecs_range'), $
                 background=255, color=0, charsize=n_plots * charsize, $
                 clip_thick=2.0, psym=1
  
  mg_range_plot, hours, sgs_deczr, $
                 title=pdate + ' UCoMP DECZR: Spar Guider System (SGS) Declination Zero Point Offset', $
                 xtitle='Hours [UT]', ytitle='SGS DECZR Zero Point Offset [arcsec]', $
                 xrange=time_range, $
                 ystyle=1, yrange=sgsdeczr_range, $
                 background=255, color=0, charsize=n_plots * charsize, $
                 clip_thick=2.0

  sgs_dec_gif_filename  = filepath(run.date + '.ucomp.sgs.dec.gif', $
                                   root=engineering_dir)
  mg_log, 'SGS DEC GIF: %s', file_basename(sgs_dec_gif_filename), $
          name=run.logger_name, $
          /debug
  write_gif, sgs_dec_gif_filename, tvrd()

  done:
end
