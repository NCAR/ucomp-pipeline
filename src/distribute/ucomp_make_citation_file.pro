; docformat = 'rst'

;+
; Use the citation template file to produce the UCoMP citation file for
; distribution.
;
; :Params:
;   template_filename : in, required, type=string
;     full path of template file
;   output_filename : in, required, type=string
;     full path of output filename
;-
pro ucomp_make_citation_file, template_filename, output_filename
  compile_opt strictarr

  template = mgfftemplate(template_filename)
  date_fmt = '(C(CDI, " ", CMoa, " ", CYI4))'
  date = string(systime(/julian), format=date_fmt)
  template->process, {date: date}, output_filename
  obj_destroy, template
end
