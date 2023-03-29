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

  elliptic = 0B

  for f = 0L, n_files - 1L do begin
    restore, files[f]
    p = ucomp_find_occulter(double(img), $
                            radius_guess=radius_guess, $
                            center_guess=center_guess, $
                            dradius=80.0, $
                            elliptic=elliptic, $
                            chisq=chisq, $
                            error=error)
    if (error ne 0L) then begin
      print, f + 1L, format='[%03d]: failed to converge'
      continue
    endif

    offset = p[0:1] - center_guess
    computed_radius = p[2]

    ; compare to dx, dy, and radius stored in save file
    print, f + 1L, offset[0], dx, offset[1], dy, computed_radius, radius, chisq, $
           format='[%03d] x: %0.3f (%0.3f), y: %0.3f (%0.3f), radius: %0.3f (%0.3f), chisq: %0.2f'

    x_diff[f]      = offset[0] - dx
    y_diff[f]      = offset[1] - dy
    radius_diff[f] = computed_radius - radius
  endfor

  set_plot, 'PS'
  device, filename='centering-test.ps', xsize=8, ysize=10, /inches, $
          /color, bits_per_pixel=8

  !p.multi = [0, 1, 3]
  charsize = 1.75
  title = string(sqrt(total(x_diff^2) / n_files), mean(x_diff), $
                 format='x-centoid, rms: %0.3f, offset: %0.3f')
  print, title
  plot, x_diff, $
        xstyle=1, ystyle=1, xtitle='Image number', $
        yrange=[-0.2, 0.2], ytitle='x-difference', $
        title=title, $
        charsize=charsize
  title = string(sqrt(total(y_diff^2) / n_files), mean(y_diff), $
                 format='y-centoid, rms: %0.3f, offset: %0.3f')
  print, title
  plot, y_diff, $
        xstyle=1, ystyle=1, xtitle='Image number', $
        yrange=[-0.2, 0.2], ytitle='y-difference', $
        title=title, $
        charsize=charsize
  title = string(sqrt(total(radius_diff^2) / n_files), mean(radius_diff), $
                 format='Radius, rms: %0.3f, offset: %0.3f')
  print, title
  plot, radius_diff, $
        xstyle=1, ystyle=1, xtitle='Image number', $
        yrange=[-0.1, 0.1], ytitle='Radius difference', $
        title=title, $
        charsize=charsize
  !p.multi = 0

  set_plot, 'X'
end


; main-level example program

dir = filepath('', subdir=['centering'], root='.')
ucomp_test_centering, dir

end
