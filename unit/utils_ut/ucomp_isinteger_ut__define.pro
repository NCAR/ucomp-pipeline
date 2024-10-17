; docformat = 'rst'

function ucomp_isinteger_ut::test_integers
  compile_opt strictarr

  integers = ['15', '09', '190']
  for i = 0L, n_elements(integers) - 1L do begin
    assert, ucomp_isinteger(integers[i]), '%s marked as not an integer', integers[i]
  endfor

  return, 1
end


function ucomp_isinteger_ut::test_nonintegers
  compile_opt strictarr

  nonintegers = ['1.0', '', 'word']
  for i = 0L, n_elements(nonintegers) - 1L do begin
    assert, ~ucomp_isinteger(nonintegers[i]), '%s marked as an integer', nonintegers[i]
  endfor

  return, 1
end


function ucomp_isinteger_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_isinteger'], $
                           /is_function

  return, 1
end


pro ucomp_isinteger_ut__define
  compile_opt strictarr

  define = {ucomp_isinteger_ut, inherits MGutTestCase}
end
