; docformat = 'rst'

function ucomp_data_lcvr3_ut::test_basic
  compile_opt strictarr

  restore, filepath('20210727.173842.74.ucomp.1074.l0.sav', root=mg_src_root())

  original_primary_header = primary_header
  !null = sxpar(original_primary_header, 'T_LCVR3', comment=original_t_lcvr3_comment)
  !null = sxpar(original_primary_header, 'TU_LCVR3', comment=original_tu_lcvr3_comment)

  assert, original_t_lcvr3_comment eq ' [C] Lyot LCVR2 Temp', $
          'bad original T_LCVR3 comment: %s', original_t_lcvr3_comment
  assert, original_tu_lcvr3_comment eq ' [C] Lyot LCVR2 Temp Unfiltered', $
          'bad original TU_LCVR3 comment: %s', original_tu_lcvr3_comment

  ucomp_data_lcvr3, primary_header, ext_data, ext_headers

  !null = sxpar(primary_header, 'T_LCVR3', comment=t_lcvr3_comment)
  !null = sxpar(primary_header, 'TU_LCVR3', comment=tu_lcvr3_comment)
  assert, t_lcvr3_comment eq ' [C] Lyot LCVR3 Temp', $
          'bad T_LCVR3 comment: %s', t_lcvr3_comment
  assert, tu_lcvr3_comment eq ' [C] Lyot LCVR3 Temp Unfiltered', $
          'bad TU_LCVR3 comment: %s', tu_lcvr3_comment

  return, 1
end


function ucomp_data_lcvr3_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_data_lcvr3']  

  return, 1
end


pro ucomp_data_lcvr3_ut__define
  compile_opt strictarr

  define = {ucomp_data_lcvr3_ut, inherits UCoMPutTestCase}
end
