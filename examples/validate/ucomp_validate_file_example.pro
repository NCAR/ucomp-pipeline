; main-level example program

raw_basedir = '/hao/dawn/Data/UCoMP/incoming'
process_basedir = '/hao/dawn/Data/UCoMP/process'

date = '20210725'
level = 'l1'

case level of
  'l0': begin
      basename = '20210725.223635.18.ucomp.l0.fts'
      filename = filepath(basename, $
                          subdir=[date], $
                            root=raw_basedir)
    end
  'l1': begin
      basename = '20210725.225657.ucomp.1083.l1.7.fts'
      filename = filepath(basename, $
                          subdir=[date, 'level1'], $
                          root=process_basedir)
    end
endcase

; read spec
header_spec_filename = filepath(string(level, format='ucomp.%s.validation.cfg'), $
                                subdir=['..', '..', 'resource', 'validation'], $
                                root=mg_src_root())

print, basename, format='validating %s...'
is_valid = ucomp_validate_file(filename, header_spec_filename, error_msg=error_msg)
print, is_valid ? 'Valid' : 'Not valid'
if (~is_valid) then begin
  print, transpose(error_msg)
endif

end
