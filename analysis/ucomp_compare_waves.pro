; docformat = 'rst'


pro ucomp_compare_waves, date, wave_angle_savfile, l2_file, subtitle=subtitle
  compile_opt strictarr

  ; restores `wave_angle` and `angle_error`
  restore, wave_angle_savfile, /verbose

  azimuth = readfits(l2_file, exten_no=11)
  noise_mask = readfits(l2_file, exten_no=6)

  dims = size(azimuth, /dimensions)

  field_radius = 400.0
  primary_header = headfits(l2_file, exten=0)
  radius = sxpar(primary_header, 'RADIUS')
  post_angle = sxpar(primary_header, 'POST_ANG')
  p_angle = sxpar(primary_header, 'SOLAR_P0')
  mask = ucomp_mask(dims, $
                    field_radius=field_radius, $
                    occulter_radius=occulter_radius, $
                    post_angle=post_angle, $
                    p_angle=p_angle)

  mask_indices = where(mask and noise_mask)

  ; convert wave_angle to 0.0 to 180.0 degrees
  negative_indices = where(wave_angle lt 0.0)
  wave_angle[negative_indices] += 180.0

  data = transpose([[wave_angle[mask_indices]], [azimuth[mask_indices]]])
  nbins = 180L
  hist = mg_hist_nd(data, nbins=nbins, minimum=0.0, maximum=180.0)

  x = 180.0 / nbins[0] * findgen(nbins[0] + 1L)
  y = 180.0 / nbins[1] * findgen(nbins[1] + 1L)

  orig_device = !d.name
  set_plot, 'Z'
  device, set_resolution=[800, 800], $
          decomposed=0, $
          set_pixel_depth=24

  mg_image, bytscl(hist, min=0.0, max=15.0), x, y, $
            charsize=1.2, /axes, $
            title=string(date, subtitle, $
                         format='Compare wave angle to azimuth for %d (%s)'), $
            xstyle=1, xticks=6, xtickformat='(F0.1)', xtitle='Wave angle', $
            ystyle=1, yticks=6, ytickformat='(F0.1)', ytitle='Azimuth', $
            ticklen=-0.005

  im = tvrd(true=1)
  set_plot, orig_device
  output_filename = filepath(string(date, subtitle, format='%s.ucomp.waves_v_azimuth.%s.png'), $
                             root=file_dirname(wave_angle_savfile))
  write_png, output_filename, im
end


; main-level example program

dates = ['20220221', '20220609', '20220823']
programs = ['synoptic', 'waves', 'waves']
root_dir = '/path/to/waves'

spatial = ['spatial', 'nospatial']
weights = ['weights1', 'weightszihao']

for d = 0L, n_elements(dates) - 1L do begin
  for s = 0L, n_elements(spatial) - 1L do begin
    for w = 0L, n_elements(weights) - 1L do begin
      subtitle = string(spatial[s], weights[w], format='%s-%s')
      date_dir = string(dates[d], subtitle, format='%s.%s')

      wave_angle_basename = 'wave_angle_3.5mHz_smoothed_new.sav'
      wave_angle_filename = filepath(wave_angle_basename, subdir=date_dir, root=root_dir)
      l2_basename = string(dates[d], programs[d], format='%s.ucomp.1074.l2.%s.mean.fts')
      l2_filename = filepath(l2_basename, subdir=date_dir, root=root_dir)

      ucomp_compare_waves, dates[d], wave_angle_filename, l2_filename, subtitle=subtitle
    endfor
  endfor
endfor

end
