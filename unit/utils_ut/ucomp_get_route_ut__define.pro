; docformat = 'rst'

function ucomp_get_route_ut::test_basic
  compile_opt strictarr

  routing_file = filepath('example_routing.cfg', root=mg_src_root())

  date = '20200101'
  dir = ucomp_get_route(routing_file, date, 'raw', found=found)
  assert, dir eq '/hao/machine4/Data/UCoMP/incoming'
  assert, found, 'date not found', date

  date = '20210101'
  dir = ucomp_get_route(routing_file, date, 'raw', found=found)
  assert, dir eq '/hao/machine5/Data/UCoMP/incoming'
  assert, found, 'date not found', date

  date = '20200101'
  dir = ucomp_get_route(routing_file, date, 'process', found=found)
  assert, dir eq '/hao/machine7/Data/UCoMP/process'
  assert, found, 'date not found', date

  date = '20210101'
  dir = ucomp_get_route(routing_file, date, 'process', found=found)
  assert, dir eq '/hao/machine8/Data/UCoMP/process'
  assert, found, 'date not found', date

  return, 1
end


function ucomp_get_route_ut::test_badtype
  compile_opt strictarr
  @error_is_pass

  dir = ucomp_get_route(routing_file, '20210101', 'engineering', found=found)
  assert, dir eq '/hao/machine8/Data/UCoMP/process'

  return, 0
end


function ucomp_get_route_ut::test_baddate
  compile_opt strictarr

  routing_file = filepath('example_routing.cfg', root=mg_src_root())
  dir = ucomp_get_route(routing_file, '20190101', 'process', found=found)

  assert, found eq 0, 'found non-existent date'
  assert, n_elements(date) eq 0, 'non-existent directory returned'

  return, 1
end


function ucomp_get_route_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_get_route', /is_function

  return, 1
end


pro ucomp_get_route_ut__define
  compile_opt strictarr

  define = { ucomp_get_route_ut, inherits UCoMPutTestCase }
end
