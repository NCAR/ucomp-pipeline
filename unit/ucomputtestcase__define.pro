function ucomputtestcase::get_config_filename, flag
  compile_opt strictarr

  _flag = mg_default(flag, 'unit')
  
  config_filename = mg_default(config_filename, $
                               filepath(string(_flag, format='ucomp.%s.cfg'), $
                                        subdir=['..', '..', 'ucomp-config'], $
                                        root=self.root))
  return, config_filename
end


function ucomputtestcase::get_run, date=date, mode=mode, config_filename=config_filename
  compile_opt strictarr

  _date = mg_default(date, '20210715')
  _mode = mg_default(mode, 'unit')
  _config_filename = mg_default(config_filename, self->get_config_filename())

  run = ucomp_run(_date, _mode, _config_filename)
  return, run
end


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
