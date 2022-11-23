; docformat = 'rst'

pro ucomp_make_docs
  compile_opt strictarr

  args = command_line_args(count=nargs)
  root = nargs gt 1L ? args[0] : mg_src_root()   ; location of this file

  idldoc, root=filepath('src', subdir=['..'], root=root), $
          output='api-docs', $
          overview=filepath('overview.txt', subdir=['..', 'docs'], root=root), $
          format_style='rst', $
          title='UCoMP pipeline', $
          subtitle=' IDL API documentation', $
          /statistics, $
          /use_latex, $
          /embed
end
