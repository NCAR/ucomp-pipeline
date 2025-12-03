; docformat = 'rst'

function ucomp_data_lcvrelx_ut::test_basic
  compile_opt strictarr

  restore, filepath('20210727.173842.74.ucomp.1074.l0.sav', root=mg_src_root())

  original_primary_header = primary_header
  !null = sxpar(original_primary_header, 'LCVRELX', comment=original_lcvrelx_comment)

  assert, original_lcvrelx_comment eq ' [ms] Delay after LCVR turning before data', $
          'bad original LCVRELX comment: %s', original_lcvrelx_comment

  ucomp_data_lcvrelx, primary_header, ext_data, ext_headers

  !null = sxpar(primary_header, 'LCVRELX', comment=lcvrelx_comment)
  assert, lcvrelx_comment eq ' [s] delay after LCVR tuning before data', $
          'bad LCVRELX comment: %s', lcvrelx_comment

  return, 1
end


function ucomp_data_lcvrelx_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_data_lcvrelx']

  return, 1
end


pro ucomp_data_lcvrelx_ut__define
  compile_opt strictarr

  define = {ucomp_data_lcvrelx_ut, inherits UCoMPutTestCase}
end
