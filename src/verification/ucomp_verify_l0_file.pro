; docformat = 'rst'

function ucomp_verify_l0_file_checkspec, specline, keyword_value, n_found, $
                                         msg=error_msg
  compile_opt strictarr

  required = 0B
  type     = 0L
  value    = !null
  values   = !null

  if (size(keyword_value, /type) eq 7) then begin
    keyword_value = strtrim(keyword_value, 2)
  endif

  tokens = strtrim(strsplit(specline, ',', /extract, count=n_tokens), 2)
  for t = 0L, n_tokens - 1L do begin
    parts = strsplit(tokens[t], '=', /extract, count=n_parts)
    case parts[0] of
      'required': required = 1B
      'value': value = parts[1]
      'values': begin
          values = strsplit(strmid(parts[1], 1, strlen(parts[1]) - 2), $
                            '|', $
                            /extract, $
                            count=n_values)
        end
      'type': begin
          case strlowcase(parts[1]) of
            'boolean': type = 1
            'int': type = 3
            'float': type = 5
            'str': type = 7
          endcase
        end
    endcase
  endfor

  if (n_elements(value) gt 0L) then begin
    if (type eq 1) then begin
      value = byte(long(value))
    endif else value = fix(value, type=type)
  endif

  if (n_elements(values) gt 0L) then values = fix(values, type=type)

  if ((n_found eq 0) && (required eq 0B)) then return, 1B

  keyword_type = size(keyword_value, /type)
  ;if (keyword_type ne type) then begin
  ;  error_msg = string(keyword_type, type, $
  ;                     format='(%"type of keyword (%d) not spec type (%d)")')
  ;  return, 0B
  ;endif

  if (n_elements(value) gt 0L) then begin
    if (keyword_value ne value) then begin
      error_msg = string(keyword_value, format='(%"wrong value: %s")')
      return, 0B
    endif
  endif

  if (n_elements(values) gt 0L) then begin
    ind = where(keyword_value eq values, count)
    if (count ne 1L) then begin
      error_msg = string(keyword_value, format='(%"not one of possible values: %s")')
      return, 0B
    endif
  endif

  return, 1B
end


function ucomp_verify_l0_file_checkheader, header, type, spec, msg=error_msg
  compile_opt strictarr

  keywords = mg_fits_keywords(header, count=n_keywords)
  spec_keywords = spec->options(section=type, count=n_spec_keywords)

  if (n_keywords gt n_spec_keywords) then begin
    error_msg = string(n_keywords, n_spec_keywords, $
                       format='(%"more keywords (%d) than spec (%d)")')
    return, 0B
  endif

  for k = 0L, n_spec_keywords - 1L do begin
    specline = spec->get(spec_keywords[k], section=type)
    value = sxpar(header, spec_keywords[k], count=n_found)
    is_valid = ucomp_verify_l0_file_checkspec(specline, value, n_found, $
                                              msg=error_msg)
    if (~is_valid) then begin
      error_msg = string(spec_keywords[k], error_msg, format='(%"%s: %s")')
      return, 0B
    endif
  endfor

  for k = 0L, n_keywords - 1L do begin
    value = spec->get(keywords[k], section=type, found=found)
    if (~found) then begin
      error_msg = string(keywords[k], $
                         format='(%"keyword %s not found in spec")')
      return, 0B
    endif
  endfor

  return, 1B
end


function ucomp_verify_l0_file_checkdata, data, $
                                         type=type, $
                                         n_dimensions=n_dimensions, $
                                         dimensions=dimensions, $
                                         msg=error_msg
  compile_opt strictarr

  _type = size(data, /type)
  if (_type ne type) then begin
    error_msg = string(_type, format='(%"wrong type for data: %d")')
    return, 0B
  endif

  _n_dims = size(data, /n_dimensions)
  if (_n_dims ne n_dimensions) then begin
    error_msg = string(_n_dims, format='(%"wrong number of dims for data: %d")')
    return, 0B
  endif

  if (_n_dims ne 0L) then begin
    _dims = size(data, /dimensions)
    if (~array_equal(_dims, dimensions)) then begin
      error_msg = string(strjoin(strtrim(_dims, 2), ', '), $
                         format='(%"wrong dims for data: [%s]")')
      return, 0B
    endif
  endif

  return, 1B
end


;+
; Verify that an L0 file matches the specification.
;
; :Returns:
;   1 if valid, 0 if not
;
; :Params:
;   filename : in, required, type=string
;     L0 file to verify
;
; :Keywords:
;   error_msg : out, optional, type=string
;     set to a named variable to retrieve the problem with the file (at least
;     the first problem encountered), empty string if no problem
;-
function ucomp_verify_l0_file, filename, error_msg=error_msg
  compile_opt strictarr

  error_msg = ''

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    error_msg = !error_state.msg
    is_valid = 0B
    goto, done
  endif

  ucomp_read_raw_data, filename, $
                       primary_data=primary_data, $
                       primary_header=primary_header, $
                       ext_data=ext_data, $
                       ext_headers=ext_headers, $
                       n_extensions=n_extensions

  ; check primary data
  is_valid = ucomp_verify_l0_file_checkdata(primary_data, $
                                            type=3, $
                                            n_dimensions=0, $
                                            msg=error_msg)
  if (~is_valid) then begin
    error_msg = 'primary data: ' + error_msg
    goto, done
  endif

  ; read spec
  l0_header_spec_filename = filepath('ucomp.l0.verification.cfg', $
                                     root=mg_src_root())
  l0_header_spec = mg_read_config(l0_header_spec_filename)

  ; check primary header against header spec
  is_valid = ucomp_verify_l0_file_checkheader(primary_header, $
                                              'primary', $
                                              l0_header_spec, $
                                              msg=error_msg)
  if (~is_valid) then begin
    error_msg = 'primary header: ' + error_msg
    goto, done
  endif

  ; check extension data
  is_valid = ucomp_verify_l0_file_checkdata(ext_data, $
                                            type=4, $
                                            n_dimensions=5, $
                                            dimensions=[1280, 1024, 4, 2, n_extensions], $
                                            msg=error_msg)
  if (~is_valid) then begin
    error_msg = 'ext data: ' + error_msg
    goto, done
  endif

  ; check extensions
  for e = 1, n_extensions do begin
    ; check ext header against spec
    is_valid = ucomp_verify_l0_file_checkheader(ext_headers[e - 1], $
                                                'extension', $
                                                l0_header_spec, $
                                                msg=error_msg)
    if (~is_valid) then begin
      error_msg = string(e, error_msg, format='(%"ext %d: %s")')
      goto, done
    endif
  endfor

  ; it's valid if it makes it to here
  is_valid = 1B

  done:

  ; cleanup
  if (obj_valid(l0_header_spec)) then obj_destroy, l0_header_spec
  if (obj_valid(ext_headers)) then obj_destroy, ext_headers

  return, is_valid
end


; main-level example program

basename = '20181102.020900.ucomp.fts'
filename = filepath(basename, $
                    subdir=['..', '..', 'analysis'], $
                    root=mg_src_root())

is_valid = ucomp_verify_l0_file(filename, error_msg=error_msg)
print, is_valid ? 'Valid' : 'Not valid'
if (~is_valid) then begin
  print, error_msg
endif

end
