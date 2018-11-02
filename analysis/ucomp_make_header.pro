; docformat = 'rst'

function ucomp_make_header, template_filename, data, hash, _extra=e
  compile_opt strictarr

  ; read template
  n_lines = file_lines(template_filename)
  template = strarr(n_lines)
  openr, lun, template_filename, /get_lun
  readf, lun, template
  free_lun, lun

  mkhdr, header, data, _extra=e
  header_list = list()

  for i = 0L, n_lines - 1L do begin
    if (strmid(template[i], 0, 1) eq '#') then continue
    if (strmid(template[i], 0, 7) eq 'COMMENT') then begin
      line = template[i]
      len = strlen(line)
      case 1 of
        len lt 80: line += strjoin(strarr(80 - len) + ' ')
        len gt 80: line = strmid(line, 0, 80)
        else:
      endcase
      header_list->add, line
      continue
    endif

    tokens = strsplit(template[i], '=/', escape='\', /extract, count=n_tokens)

    name    = tokens[0]
    value   = strtrim(mg_subs(tokens[1], hash), 2)
    is_string = strmid(value, 0, 1) eq "'"
    comment = n_tokens eq 2 ? '' : strtrim(mg_subs(tokens[2], hash), 2)

    ; add name
    line = string(name, format='(%"%-8s= ")')

    ; add value
    if (is_string) then begin
      len = strlen(value)
      case 1 of
        len le 20: line += string(value, format='(%"%-20s")')
        len gt 70: line += string(strmid(value, 0, 69), format='(%"%s''")')
        else: line += string(value, format='(%"%s")')
      endcase
    endif else begin
      line += string(value, format='(%"%20s")')
    endelse

    ; add comment
    line += string(comment, format='(%" / %s")')

    ; make length 80
    len = strlen(line)
    case 1 of
      len lt 80: line += strjoin(strarr(80 - len) + ' ')
      len gt 80: line = strmid(line, 0, 80)
      else:
    endcase

    header_list->add, line
   endfor

  header = [header[0:-5], header_list->toArray(), header[-4:-1]]
  obj_destroy, header_list

  return, header
end


 ; main-level example program

dt_format = '(C(CYI, "-", CMoI02, "-", CDI02, "T", CHI02, ":", CMI02, ":", CSI02))'

primary_hash = ucomp_generate_primary_header()

primary_header_template = filepath('ucomp_l0_primary_header.tt', root=mg_src_root())
primary_header = ucomp_make_header(primary_header_template, 0.0, primary_hash, /extend)
print, transpose(primary_header)
print, strlen(primary_header)

end
