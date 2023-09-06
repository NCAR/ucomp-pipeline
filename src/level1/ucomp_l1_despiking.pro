; docformat = 'rst'

;+
; Remove spikes.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, out, required, type="fltarr(nx, ny, n_pol_states, n_cameras, nexts)"
;     extension data
;   headers : in, required, type=list
;     extension headers as list of `strarr`
;   backgrounds : out, type="fltarr(nx, ny, n_pol_states, n_cameras, n_exts)"
;     background images
;   background_headers : in, required, type=list
;     extension headers for background images as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_despiking, file, $
                        primary_header, $
                        data, headers, $
                        backgrounds, background_headers, $
                        run=run, status=status
  compile_opt strictarr

  status = 0L

  dims = size(data, /dimensions)
  n_columns    = dims[0]
  n_rows       = dims[1]
  n_polstates  = dims[2]
  n_cameras    = dims[3]
  n_extensions = n_elements(headers)

  ; TODO: this should be in a config file and probably depends on wave region
  max_difference = 10.0

  annulus = ucomp_annulus(file.occulter_radius + 3.0, $
                          run->epoch('field_radius') - 3.0, $
                          dimensions=dims)

  kernel_size = 5L
  kernel = fltarr(kernel_size, kernel_size) + 1.0
  kernel[kernel_size / 2L, kernel_size / 2L] = 0.0
  kernel /= total(kernel, /preserve_type)

  mask = bytarr(n_columns, n_rows, n_cameras, n_extensions)
  for e = 0L, n_extensions - 1L do begin
    n_bad_ext_pixels = lonarr(2)
    for c = 0L, n_cameras - 1L do begin
      d = data[*, *, 0, c, e]

      s = convol(d, kernel, /edge_zero)

      mask[*, *, c, e] = annulus * (abs(s - d) gt max_difference)
      bad_pixel_indices = where(mask[*, *, c, e], n_bad_pixels)
      n_bad_ext_pixels[c] += n_bad_pixels

      mg_log, '%d spiked pixels in annulus in cam %d, ext %d', $
              n_bad_pixels, c, e, $
              name=run.logger_name, /debug
      d[bad_pixel_indices] = s[bad_pixel_indices]
      data[*, *, 0, c, e] = d

      ; TODO: don't go close to occulter
      ; TODO: save hot pixels to compare across files and days
    endfor

    ; put the # of spiked pixels corrected in the keywords N{R,T}SPIKE
    h = headers[e]
    ucomp_addpar, h, 'NRSPIKE', n_bad_ext_pixels[0], $
                  comment='number of spiked pixels corrected in RCAM'
                  after='REMFRAME'
    ucomp_addpar, h, 'NTSPIKE', n_bad_ext_pixels[1], $
                  comment='number of spiked pixels corrected in TCAM'
                  after='NRSPIKE'
    headers[e] = h
  endfor

  done:
end
