; docformat = 'rst'


pro ucomp_compare_waves, date, wave_angle_savfile, l2_file
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

  window, xsize=800, ysize=800
  mg_image, bytscl(hist, min=0.0, max=15.0), x, y, $
            charsize=1.2, /axes, $
            title=string(date, format='Compare wave angle to azimuth for %d'), $
            xstyle=1, xticks=6, xtickformat='(F0.1)', xtitle='Wave angle', $
            ystyle=1, yticks=6, ytickformat='(F0.1)', ytitle='Azimuth', $
            ticklen=-0.005
end


; main-level example program

date = '20220609'
; date = '20220823'
root_dir = 'path/to/waves/directory'

wave_angle_basename = 'wave_angle_3.5mHz_smoothed_new.sav'
wave_angle_filename = filepath(wave_angle_basename, subdir=date, root=root_dir)
l2_basename = date + '.ucomp.1074.l2.waves.mean.fts'
l2_filename = filepath(l2_basename, subdir=date, root=root_dir)

ucomp_compare_waves, date, wave_angle_filename, l2_filename

end
