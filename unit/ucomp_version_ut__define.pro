; docformat = 'rst'

function ucomp_version_ut::test_basic, output=output
  compile_opt strictarr

  version = ucomp_version(revision=revision, branch=branch)
  assert, size(version, /type) eq 7, 'wrong type for version'
  assert, size(revision, /type) eq 7, 'wrong type for revision'
  assert, size(branch, /type) eq 7, 'wrong type for branch'

  output = string(version, revision, branch, format='(%"version %s [%s] (%s)")')

  return, 1
end


function ucomp_version_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_version', /is_function

  return, 1
end


pro ucomp_version_ut__define
  compile_opt strictarr

  define = { ucomp_version_ut, inherits UCoMPutTestCase }
end
