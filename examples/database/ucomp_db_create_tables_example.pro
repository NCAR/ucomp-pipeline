; main-level example program

config_filename = filepath('ucomp.latest.cfg', $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

ucomp_db_create_tables, config_filename

end
