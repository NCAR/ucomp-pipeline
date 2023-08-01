; docformat = 'rst'

function ucomp_isinteger, s
  compile_opt strictarr

  return, stregex(s, '^[[:digit:]]+$', /boolean)
end
