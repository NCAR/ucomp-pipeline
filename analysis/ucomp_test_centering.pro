; docformat = 'rst'

pro ucomp_test_centering, directory
  compile_opt strictarr

  nx = 1280L
  ny = 1024L
  radius_guess = 330.0
  center_guess = [(nx - 1.0) / 2.0, (ny - 1.0) / 2.0]

  files = file_search(filepath('Img*.sav', root=directory), count=n_files)
  files = files[sort(files)]

  x_diff      = fltarr(n_files)
  y_diff      = fltarr(n_files)
  radius_diff = fltarr(n_files)

  for f = 0L, n_files - 1L do begin
    restore, files[f]
    p = ucomp_find_occulter(double(img), $
                            radius_guess=radius_guess, $
                            center_guess=center_guess, $
                            dradius=80.0, $
                            error=error, $
                            /elliptical)

    ; compare to dx, dy, and radius stored in save file
    print, f + 1L, p[0] - center_guess[0], dx, p[1] - center_guess[1], dy, p[2], radius, $
           format='[%03d] x: %0.3f (%0.3f), y: %0.3f (%0.3f), radius: %0.3f (%0.3f)'

    x_diff[f]      = p[0] - center_guess[0] - dx
    y_diff[f]      = p[1] - center_guess[1] - dy
    radius_diff[f] = p[2] - radius
  endfor

  set_plot, 'PS'
  device, filename='centering-test.ps', xsize=8, ysize=10, /inches, $
          /color, bits_per_pixel=8

  !p.multi = [0, 1, 3]
  charsize=1.75
  plot, x_diff, $
        xstyle=1, ystyle=1, xtitle='Image number', $
        yrange=[-0.2, 0.2], ytitle='x-difference', $
        title=string(sqrt(total(x_diff^2) / n_files), mean(x_diff), $
                     format='x-centoid, rms: %0.3f, offset: %0.3f'), $
        charsize=charsize
  plot, y_diff, $
        xstyle=1, ystyle=1, xtitle='Image number', $
        yrange=[-0.2, 0.2], ytitle='y-difference', $
        title=string(sqrt(total(y_diff^2) / n_files), mean(y_diff), $
                     format='y-centoid, rms: %0.3f, offset: %0.3f'), $
        charsize=charsize
  plot, radius_diff, $
        xstyle=1, ystyle=1, xtitle='Image number', $
        yrange=[-0.2, 0.2], ytitle='Radius difference', $
        title=string(sqrt(total(radius_diff^2) / n_files), mean(radius_diff), $
                     format='Radius, rms: %0.3f, offset: %0.3f'), $
        charsize=charsize
  !p.multi = 0

  set_plot, 'X'
end


; main-level example program

dir = filepath('', subdir=['centering'], root='.')
ucomp_test_centering, dir

end
