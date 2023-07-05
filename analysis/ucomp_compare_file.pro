pro ucomp_compare_file, compare
  compile_opt strictarr

  _compare = n_elements(compare) eq 0L ? 'debanding' : compare

  case _compare of
    'gain': begin
        f_steve = 'ucomp-intermediate-steve/data_after_sum.sav'
        restore, f_steve, /verbose
        center_steve = data_cube[*, *, 0, 1, 0, 0]

        f_mike = 'ucomp-intermediate-mike/20220901.182014.ucomp.1074.apply_gain.3.fts'
        fits_open, f_mike, fcb
        fits_read, fcb, center_mike, exten_no=2
        fits_close, fcb
        center_mike = reverse(center_mike[*, *, 0, 0], 1)

        display_max = 0.125
      end

    'demod': begin
        f_steve = 'ucomp-intermediate-steve/data_after_pol.sav'
        restore, f_steve, /verbose
        center_steve = data_cube[*, *, 0, 1, 0, 0]

        f_mike = 'ucomp-intermediate-mike/20220901.182014.ucomp.1074.demodulation.3.fts'
        fits_open, f_mike, fcb
        fits_read, fcb, center_mike, exten_no=2
        fits_close, fcb
        center_mike = reverse(center_mike[*, *, 0, 0], 1)

        display_max = 0.125
      end

    'continuum_subtraction': begin
        f_steve = 'ucomp-intermediate-steve/data_after_dist.sav'
        restore, f_steve, /verbose
        center_steve = corona[*, *, 0, 1, 0]

        f_mike = 'ucomp-intermediate-mike/20220901.182014.ucomp.1074.continuum_subtraction.3.fts'
        fits_open, f_mike, fcb
        fits_read, fcb, center_mike, exten_no=2
        fits_close, fcb

        center_mike = center_mike[*, *, 0, 0]
        ;center_mike = reverse(center_mike, 2)

        ;tvlct, rgb, /get
        ;loadct, 0
        ;mg_image, bytscl(center_mike, 0.0, 80.0), /new, title='Mike'
        ;mg_image, bytscl(center_steve, 0.0, 80.0), /new, title='Steve'
        ;tvlct, rgb

        display_max = 0.125
      end

    'debanding': begin
      f_steve = 'ucomp-intermediate-steve/data_after_deband.sav'
      restore, f_steve, /verbose
      center_steve = corona[*, *, *, 1, *]
      center_steve = reform(center_steve)
      center_steve = center_steve[*, *, 0, 0]

      f_mike = 'ucomp-intermediate-mike/20220901.182014.ucomp.1074.debanding.3.fts'
      fits_open, f_mike, fcb
      fits_read, fcb, center_mike, exten_no=2
      fits_close, fcb

      center_mike = center_mike[*, *, 0, 0]
      ;center_mike = reverse(center_mike, 2)

      display_max = 0.125
    end

    'final': begin
        f_steve = 'ucomp-intermediate-steve/20220901.182014.ucomp.1074.l1.3.fts'
        fits_open, f_steve, fcb
        fits_read, fcb, primary_steve, primary_header_steve, exten_no=0
        fits_read, fcb, center_steve, header_steve, exten_no=2
        fits_close, fcb

        f_mike = 'ucomp-intermediate-mike/20220901.182014.ucomp.1074.l1.3.fts'
        fits_open, f_mike, fcb
        fits_read, fcb, primary_mike, primary_header_mike, exten_no=0
        fits_read, fcb, center_mike, exten_no=2
        fits_close, fcb

        center_steve = center_steve[*, *, 0]
        center_mike  = center_mike[*, *, 0]


        xoffset0_steve = sxpar(primary_header_steve, 'XOFFSET0')
        yoffset0_steve = sxpar(primary_header_steve, 'YOFFSET0')
        xoffset1_steve = sxpar(primary_header_steve, 'XOFFSET1')
        yoffset1_steve = sxpar(primary_header_steve, 'YOFFSET1')

        xoffset0_mike = sxpar(primary_header_mike, 'XOFFSET0')
        yoffset0_mike = sxpar(primary_header_mike, 'YOFFSET0')
        xoffset1_mike = sxpar(primary_header_mike, 'XOFFSET1')
        yoffset1_mike = sxpar(primary_header_mike, 'YOFFSET1')

        print, xoffset0_mike, xoffset0_steve, xoffset0_mike - xoffset0_steve, $
               format='xoffset0: mike: %0.3f, steve: %0.3f, mike-steve: %0.3f'
        print, yoffset0_mike, yoffset0_steve, yoffset0_mike - yoffset0_steve, $
               format='yoffset0: mike: %0.3f, steve: %0.3f, mike-steve: %0.3f'
        print, xoffset1_mike, xoffset1_steve, xoffset1_mike - xoffset1_steve, $
               format='xoffset1: mike: %0.3f, steve: %0.3f, mike-steve: %0.3f'
        print, yoffset1_mike, yoffset1_steve, yoffset1_mike - yoffset1_steve, $
               format='yoffset1: mike: %0.3f, steve: %0.3f, mike-steve: %0.3f'

        tvlct, rgb, /get
        loadct, 0, /silent
        ;mg_image, bytscl(center_mike, 0.0, 40.0), /new, title='Mike'
        ;mg_image, bytscl(center_steve, 0.0, 40.0), /new, title='Steve'

        display_max = 0.125
      end
    'background': begin
        f_steve = 'ucomp-intermediate-steve/20220901.182014.ucomp.1074.l1.3.fts'
        fits_open, f_steve, fcb
        fits_read, fcb, primary_steve, primary_header_steve, exten_no=0
        fits_read, fcb, center_steve, header_steve, exten_no=5
        fits_close, fcb

        f_mike = 'ucomp-intermediate-mike/20220901.182014.ucomp.1074.l1.3.fts'
        fits_open, f_mike, fcb
        fits_read, fcb, primary_mike, primary_header_mike, exten_no=0
        fits_read, fcb, center_mike, exten_no=5
        fits_close, fcb

        display_max = 0.125
      end
    'q': begin
        f_steve = 'ucomp-intermediate-steve/20220901.182014.ucomp.1074.l1.3.fts'
        fits_open, f_steve, fcb
        fits_read, fcb, primary_steve, primary_header_steve, exten_no=0
        fits_read, fcb, center_steve, header_steve, exten_no=2
        fits_close, fcb

        f_mike = 'ucomp-intermediate-mike/20220901.182014.ucomp.1074.l1.3.fts'
        fits_open, f_mike, fcb
        fits_read, fcb, primary_mike, primary_header_mike, exten_no=0
        fits_read, fcb, center_mike, exten_no=2
        fits_close, fcb

        center_steve = center_steve[*, *, 1]
        center_mike  = center_mike[*, *, 1]

        display_max = 0.125
      end
    'u': begin
      f_steve = 'ucomp-intermediate-steve/20220901.182014.ucomp.1074.l1.3.fts'
      fits_open, f_steve, fcb
      fits_read, fcb, primary_steve, primary_header_steve, exten_no=0
      fits_read, fcb, center_steve, header_steve, exten_no=2
      fits_close, fcb

      f_mike = 'ucomp-intermediate-mike/20220901.182014.ucomp.1074.l1.3.fts'
      fits_open, f_mike, fcb
      fits_read, fcb, primary_mike, primary_header_mike, exten_no=0
      fits_read, fcb, center_mike, exten_no=2
      fits_close, fcb

      center_steve = center_steve[*, *, 2]
      center_mike  = center_mike[*, *, 2]

      display_max = 0.125
    end
    'v': begin
      f_steve = 'ucomp-intermediate-steve/20220901.182014.ucomp.1074.l1.3.fts'
      fits_open, f_steve, fcb
      fits_read, fcb, primary_steve, primary_header_steve, exten_no=0
      fits_read, fcb, center_steve, header_steve, exten_no=2
      fits_close, fcb

      f_mike = 'ucomp-intermediate-mike/20220901.182014.ucomp.1074.l1.3.fts'
      fits_open, f_mike, fcb
      fits_read, fcb, primary_mike, primary_header_mike, exten_no=0
      fits_read, fcb, center_mike, exten_no=2
      fits_close, fcb

      center_steve = center_steve[*, *, 3]
      center_mike  = center_mike[*, *, 3]

      display_max = 0.125
    end
  endcase

  diff = center_mike - center_steve

  device, decomposed=0
  ucomp_loadct, 'quv'

  mg_image, bytscl(diff, -display_max, display_max), /new, $
            title=string(_compare, -display_max, display_max, $
                         format='Difference (Mike - Steve): Step: %s [bytscl(diff, %0.3f (cyan), %0.3f (pink)]')

  percent_display_min = -5.0
  percent_display_max =  5.0
  percent_diff =  100.0 * diff / center_steve
  mg_image, bytscl(percent_diff,  percent_display_min, percent_display_max), /new, $
            title=string(_compare, percent_display_min, percent_display_max, $
                         format='%% Difference (Mike - Steve): Step: %s [bytscl(diff, %0.1f (cyan), %0.1f (pink)]')
;  rdpix, percent_diff
end


; main-level example program

;ucomp_compare_file, 'gain'
;ucomp_compare_file, 'demod'
;ucomp_compare_file, 'continuum_subtraction'
;ucomp_compare_file, 'debanding'
ucomp_compare_file, 'final'
ucomp_compare_file, 'background'
ucomp_compare_file, 'q'
ucomp_compare_file, 'u'
ucomp_compare_file, 'v'

end
