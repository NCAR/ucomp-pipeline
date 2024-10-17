; docformat = 'rst'

function ucomp_movepar_ut::test_basic
  compile_opt strictarr

  mkhdr, header, 4, [1280, 1024]
  sxaddpar, header, 'TEST1', 1
  sxaddpar, header, 'TEST2', 2

  ucomp_movepar, header, 'TEST1', after='TEST2'
  assert, strmid(header[9], 0, 5) eq 'TEST1', 'wrong location for TEST1 with AFTER'

  ucomp_movepar, header, 'TEST1', before='TEST2'
  assert, strmid(header[8], 0, 5) eq 'TEST1', 'wrong location for TEST1 with BEFORE'

  ucomp_movepar, header, 'TEST1'
  assert, strmid(header[9], 0, 5) eq 'TEST1', 'wrong location for TEST1 with no location'

  return, 1
end


function ucomp_movepar_ut::test_badargs
  compile_opt strictarr
  @error_is_pass

  mkhdr, header, 4, [1280, 1024]
  sxaddpar, header, 'TEST1', 1
  sxaddpar, header, 'TEST2', 2

  ucomp_movepar, header, 'TEST1', after='TEST2', before='TEST2'
  
  return, 1
end


function ucomp_movepar_ut::test_noend
  compile_opt strictarr
  @error_is_pass

  mkhdr, header, 4, [1280, 1024]
  sxaddpar, header, 'TEST1', 1
  sxaddpar, header, 'TEST2', 2
  header = header[[lindgen(10), 11, 12]]

  ucomp_movepar, header, 'TEST1'
  
  return, 1
end


function ucomp_movepar_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_movepar']
  

  return, 1
end


pro ucomp_movepar_ut__define
  compile_opt strictarr

  define = {ucomp_movepar_ut, inherits MGutTestCase}
end
