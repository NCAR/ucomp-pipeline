configure_file(ucomp_include.sh.in ucomp_include.sh @ONLY)
configure_file(ucomp.in ucomp @ONLY)

install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/ucomp_include.sh
                 ${CMAKE_CURRENT_BINARY_DIR}/ucomp
        DESTINATION bin)

install(PROGRAMS ucomp_validate.sh
		 ucomp_validate_dates.sh
                 ucomp_mail_results.sh
		 ucomp_create_tables.sh
		 ucomp_calibrate.sh
		 ucomp_eod.sh
		 ucomp_realtime.sh
                 ucomp_log
        DESTINATION bin)
