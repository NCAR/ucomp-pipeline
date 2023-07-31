; docformat = 'rst'

pro ucomp_plot_saturated, db, wave_region, start_date, end_date
  compile_opt strictarr

  start_components = long(ucomp_decompose_date(start_date))
  start_date_string = string(start_components, format='%04d-%02d-%02d')
  start_jd = julday(start_components[1], start_components[2], start_components[0], $
                    0.0, 0.0, 0.0)
  end_components = long(ucomp_decompose_date(end_date))
  end_date_string = string(end_components, format='%04d-%02d-%02d')
  end_jd = julday(end_components[1], end_components[2], end_components[0], $
                  0.0, 0.0, 0.0)

  producttype_results = db->query('select * from mlso_producttype where producttype="IQUV" and description like "UCoMP%%";')
  level1_producttype_id = producttype_results.producttype_id

  query = 'select * from ucomp_file where producttype_id=%d and date_obs > ''%s'' and date_obs < ''%s'' order by date_obs'
  data = db->query(query, level1_producttype_id, start_date_string, end_date_string, $
                   count=n_files, status=status, error=error, sql_statement=sql)

  jds = dblarr(n_files)
  for f = 0L, n_files - 1L do jds[f] = ucomp_dateobs2julday(data[f].date_obs)
  !null = label_date(date_format='%Y-%N-%D')

  window, xsize=800, ysize=800, $
          title='Nonlinear pixels', $
          /free
  !p.multi = [0, 2, 4]
  charsize = 2.0
  yrange = [0.0, 4000.0]
  binsize = 100
  hist_range = [0, 5000]

  plot, jds, data.n_rcam_onband_nonlinear_pixels, $
             title='RCAM onband nonlinear pixels', $
             charsize=charsize, $
             xstyle=9, xrange=[start_jd, end_jd], xtickformat='label_date', xticks=4, $
             ystyle=9, yrange=yrange, $
             color='000000'x, background='ffffff'x, $
             ;clip_thick=2.0, clip_color='0000ff'x, $
             psym=6, symsize=0.2
  h = histogram(data.n_rcam_onband_nonlinear_pixels, locations=locations, $
                min=hist_range[0], binsize=binsize, max=hist_range[1])
  mg_histplot, locations, h, color='ff0000'x, axis_color='000000'x, $
               charsize=charsize, xstyle=9, ystyle=9, $
               xtitle='DN level', ytitle='Counts', $
               title='Histogram of RCAM onband nonlinear pixels'

  plot, jds, data.n_tcam_onband_nonlinear_pixels, $
                 title='TCAM onband nonlinear pixels', $
                 charsize=charsize, $
                 xstyle=9, xrange=[start_jd, end_jd], xtickformat='label_date', xticks=4, $
                 ystyle=9, yrange=yrange, $
                 color='000000'x, background='ffffff'x, $
                 ;clip_thick=2.0, clip_color='0000ff'x, $
                 psym=6, symsize=0.2
  h = histogram(data.n_tcam_onband_nonlinear_pixels, locations=locations, $
                min=hist_range[0], binsize=binsize, max=hist_range[1])
  mg_histplot, locations, h, color='ff0000'x, axis_color='000000'x, $
               charsize=charsize, xstyle=9, ystyle=9, $
               xtitle='DN level', ytitle='Counts', $
               title='Histogram of TCAM onband nonlinear pixels'

  plot, jds, data.n_rcam_bkg_nonlinear_pixels, $
                 title='RCAM bkg nonlinear pixels', $
                 charsize=charsize, $
                 xstyle=9, xrange=[start_jd, end_jd], xtickformat='label_date', xticks=4, $
                 ystyle=9, yrange=yrange, $
                 color='000000'x, background='ffffff'x, $
                 ;clip_thick=2.0, clip_color='0000ff'x, $
                 psym=6, symsize=0.2
  h = histogram(data.n_rcam_bkg_nonlinear_pixels, locations=locations, $
                min=hist_range[0], binsize=binsize, max=hist_range[1])
  mg_histplot, locations, h, color='ff0000'x, axis_color='000000'x, $
               charsize=charsize, xstyle=9, ystyle=9, $
               xtitle='DN level', ytitle='Counts', $
               title='Histogram of RCAM bkg nonlinear pixels'

  plot, jds, data.n_tcam_bkg_saturated_pixels, $
                 title='TCAM bkg nonlinear pixels', $
                 charsize=charsize, $
                 xstyle=9, xrange=[start_jd, end_jd], xtickformat='label_date', xticks=4, $
                 ystyle=9, yrange=yrange, $
                 color='000000'x, background='ffffff'x, $
                 ;clip_thick=2.0, clip_color='0000ff'x, $
                 psym=6, symsize=0.2
  h = histogram(data.n_tcam_bkg_saturated_pixels, locations=locations, $
                min=hist_range[0], binsize=binsize, max=hist_range[1])
  mg_histplot, locations, h, color='ff0000'x, axis_color='000000'x, $
               charsize=charsize, xstyle=9, ystyle=9, $
               xtitle='DN level', ytitle='Counts', $
               title='Histogram of TCAM bkg nonlinear pixels'

  !p.multi = 0

  threshold = 1000.0
  !null = where(data.n_rcam_onband_nonlinear_pixels gt threshold $
                  or data.n_tcam_onband_nonlinear_pixels gt threshold $
                  or data.n_rcam_bkg_nonlinear_pixels gt threshold $
                  or data.n_tcam_bkg_nonlinear_pixels gt threshold, count)
  print, threshold, count, n_files, 100.0 * count / n_files, $
         format='threshold: %d -> %d/%d bad (%0.1f%%)'
end


; main-level example

start_date = '20210526'
end_date = '20221201'

config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(start_date, 'analysis', config_filename)

db = ucomp_db_connect(run->config('database/config_filename'), $
                      run->config('database/config_section'), $
                      logger_name=run.logger_name, $
                      log_statements=run->config('database/log_statements'), $
                      status=status)

; wave_regions = ['530', '637', '656', '670', '691', '706', '761', '789', '802', $
;                 '991', '1074', '1079', '1083']
wave_regions = ['1074']
for w = 0L, n_elements(wave_regions) - 1L do begin
  ucomp_plot_saturated, db, wave_regions[w], start_date, end_date
endfor

obj_destroy, [db, run]

end
