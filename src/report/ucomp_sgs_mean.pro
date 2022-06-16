; docformat = 'rst'

function ucomp_sgs_mean, sgs_values
  compile_opt strictarr

  if (n_elements(sgs_values) eq 0L) then return, !values.f_nan

  return, mean(sgs_values)
end
