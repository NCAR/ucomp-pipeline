; docformat = 'rst'

;+
; Perform demodulation.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, required, type="fltarr(nx, ny, n_pol_states, n_cameras, nexts)"
;     extension data
;   headers : in, required, type=list
;     extension headers as list of `strarr`
;   backgrounds : type=undefined
;     not used in this step
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_demodulation, file, $
                           primary_header, data, headers, backgrounds, $
                           run=run, status=status
  compile_opt strictarr

  status = 0L

  datetime = strmid(file_basename(file.raw_filename), 0, 15)

  wave_region_index = where(file.wave_region eq run.all_wave_regions, n_found)
  mg_log, 'wave region index: %d', wave_region_index[0], name=run.logger_name, /debug
  mg_log, 'TU_MOD temperature: %0.3f C', file.tu_mod, name=run.logger_name, /debug
  dmatrix_coefficients = run->get_dmatrix_coefficients(datetime=datetime, info=demod_info)
  dmatrix = ucomp_get_dmatrix(dmatrix_coefficients, $
                              file.tu_mod, $
                              wave_region_index[0])

  demodulation_method = run->config('options/demodulation_method')
  case strlowcase(demodulation_method) of
    'c': data = ucomp_quick_demodulation(dmatrix, data)
    'vectorized': begin
        ; apply dmatrix to each pixel in each extension in each camera
        dims = size(data, /dimensions)
        n_exts = n_elements(headers)

        ; dimensional transforming bulk matrix multiplication implementation
        dc = transpose(data, [0, 1, 3, 4, 2])
        non_pol_dims = product(dims[[0, 1, 3, 4]], /preserve_type)
        dc = reform(dc, non_pol_dims, dims[2])   ; reform to n x n_pol_states array
        dc = dmatrix ## dc[0L:non_pol_dims - 1L, *]
        dc = reform(dc, dims[[0, 1, 3, 4, 2]])
        data = transpose(dc, [0, 1, 4, 2, 3])
      end
    'naive': begin
        ; very naive implementation
        for x = 0L, dims[0] - 1L do begin
          for y = 0L, dims[1] - 1L do begin
            for c = 0L, dims[3] - 1L do begin
              for e = 0L, n_exts - 1L do begin
                data[x, y, *, c, e] = dmatrix ## reform(data[x, y, *, c, e])
              endfor
            endfor
          endfor
        endfor
      end
    else: message, string(demodulation_method, $
                          format='unknown demodulation method ''%s''')
  endcase

  demod_basename = run->epoch('demodulation_coeffs_basename', datetime=datetime)
  ucomp_addpar, primary_header, 'DEMOD_C', demod_basename, $
                comment=string(ucomp_idlsave2dateobs(demod_info.date), $
                               format='demod coeffs created %s')


  file.demodulated = 1B
end
