; main-level example program

date = '20211202'
dt = '20211202.185330.59'
basename = string(strmid(dt, 0, 15), format='%s.ucomp.1074.distortion.5.fts')
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, subdir=['..', '..', 'config'], root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

raw_basedir = run->config('raw/basedir')
raw_basename = string(dt, format='%s.ucomp.1074.l0.fts')
raw_filename = filepath(raw_basename, subdir=date, root=raw_basedir)

file = ucomp_file(raw_filename, run=run)

processing_basedir = run->config('processing/basedir')
filename = filepath(basename, subdir=[date, 'level1', '08-distortion'], root=processing_basedir)

ucomp_read_raw_data, filename, $
                     primary_data=primary_data, $
                     primary_header=primary_header, $
                     ext_data=ext_data, $
                     ext_headers=ext_headers, $
                     n_extensions=n_extensions

dims = size(ext_data, /dimensions)
n_pol_states = dims[2]

occulter_x = ucomp_getpar(primary_header, 'OCCLTR-X')
occulter_y = ucomp_getpar(primary_header, 'OCCLTR-Y')

occulter_id = ucomp_getpar(primary_header, 'OCCLTRID')
radius_guess = ucomp_radius_guess(occulter_id, file.wave_region, run=run)
dradius = 25.0

post_angle_guess = run->epoch('post_angle_guess')
post_angle_tolerance = run->epoch('post_angle_tolerance')

rcam_center_guess = ucomp_occulter_guess(0, date, occulter_x, occulter_y, run=run)
rcam_offband_indices = where(file.onband_indices eq 1, n_rcam_offband)
rcam_im = mean(ext_data[*, *, *, 0, rcam_offband_indices], dimension=3, /nan)
while (size(rcam_im, /n_dimensions) gt 2L) do rcam_im = mean(rcam_im, dimension=3, /nan)
rcam_im = smooth(rcam_im, 2)

occulter = ucomp_find_occulter(rcam_im, $
                               chisq=occulter_chisq, $
                               radius_guess=radius_guess, $
                               center_guess=rcam_center_guess, $
                               dradius=dradius, $
                               error=occulter_error, $
                               points=points, $
                               elliptical=elliptical)

print, rcam_center_guess, format='RCAM center guess: %f, %f'
device, decomposed=1
mg_image, bytscl(rcam_im, -20.0, 20.0), /new

; range
t = findgen(361) * !dtor
x_min = (radius_guess - dradius) * cos(t) + rcam_center_guess[0]
y_min = (radius_guess - dradius) * sin(t) + rcam_center_guess[1]
x_max = (radius_guess + dradius) * cos(t) + rcam_center_guess[0]
y_max = (radius_guess + dradius) * sin(t) + rcam_center_guess[1]

plots, points[0, *], points[1, *], /device, color='00ffff'x
plots, x_min, y_min, /device, color='ffff00'x
plots, x_max, y_max, /device, color='ffff00'x

obj_destroy, [file, run]

end
