; main-level example program

;files = file_search('/hao/dawn/Data/CoMP/engineering.reprocess-check/2014/06/18/*.bad.gif')
;frames_per_second = 2L

files = file_search('/hao/dawn/Data/KCor/raw.latest/20201008/level2/*_l2_nrgf.gif')
frames_per_second = 10L

ucomp_create_mp4, files, 'test.mp4', $
                  executable='/hao/contrib/bin/ffmpeg', $
                  frames_per_second=frames_per_second, $
                  status=status, error_message=error_message
print, status eq 0L ? 'video OK' : error_message

end
