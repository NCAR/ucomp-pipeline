; docformat = 'rst'

function ucomp_data_synoptic_ut::test_basic
  compile_opt strictarr

  mkhdr, primary_header, dist(1280, 1024), /extend, /image
  after = 'GCOUNT'

  ucomp_addpar, primary_header, 'OBS_PLAN', 'synoptic.cbk', $
                comment='observing plan', after=after

  ucomp_data_synoptic, primary_header, ext_data, ext_headers

  obs_plan = ucomp_getpar(primary_header, 'OBS_PLAN')
  assert, obs_plan eq 'oldLineFineScan.cbk', 'bad OBS_PLAN value: %s', obs_plan

  return, 1
end


function ucomp_data_synoptic_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_data_synoptic']

  return, 1
end


pro ucomp_data_synoptic_ut__define
  compile_opt strictarr

  define = {ucomp_data_synoptic_ut, inherits UCoMPutTestCase}
end
