function ucomputtestcase::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self.root = mg_src_root()

  return, 1
end


pro ucomputtestcase__define
  compile_opt strictarr

  define = { UCoMPutTestCase, inherits MGutTestCase, $
             root: '' $
           }
end
