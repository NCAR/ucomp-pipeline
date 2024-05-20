; docformat = 'rst'

;+
; Read UCoMP config file. This function handles UCoMP-specific aspects such as
; allowing a config file to inherit from another config file.
;
; :Returns:
;   `MGffSpecOptions` object
;
; :Params:
;   config_filename : in, required, type=string
;     config file to read
;
; :Keywords:
;   spec : in, optional, type=string
;     specification for config file to read
;-
function ucomp_read_config, config_filename, spec=config_spec_filename
  compile_opt strictarr

  original_options = mg_read_config(config_filename, spec=config_spec_filename)

  include_filename = original_options->get('inherit', section='config')
  if (n_elements(include_filename) gt 0L) then begin
    if (~file_test(include_filename, /regular)) then begin
      include_filename = filepath(file_basename(include_filename), $
                                  root=file_dirname(config_filename))
    endif
    parent_options = mg_read_config(include_filename, spec=config_spec_filename)
    options = mg_read_config(config_filename, $
                             defaults=parent_options, $
                             spec=config_spec_filename)
    obj_destroy, [original_options, parent_options]
  endif else options = original_options

  return, options
end
