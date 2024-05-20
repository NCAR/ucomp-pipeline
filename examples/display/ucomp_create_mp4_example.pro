; main-level example program

date = '20221123'

config_filename = filepath('ucomp.latest.cfg', $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

image_glob = filepath('*.ucomp.1074.l1.3.int.gif', $
                      subdir=[date, 'level1'], $
                      root=run->config('processing/basedir'))
image_files = file_search(image_glob, count=n_image_files)

int_mp4_basename = string(date, format='(%"%s_ucomp_int_test.mp4")')
int_mp4_filename = filepath(int_mp4_basename, $
                            subdir=[date, 'level1'], $
                            root=run->config('processing/basedir'))

ucomp_create_mp4, image_files, int_mp4_filename, run=run, status=status
help, status

obj_destroy, run

end
