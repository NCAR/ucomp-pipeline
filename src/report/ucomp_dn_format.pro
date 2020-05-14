; docformat = 'rst'

function ucomp_dn_format, axis, index, value
  compile_opt strictarr

  return, mg_float2str(long(value), places_sep=',')
end
