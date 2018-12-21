configure_file(ucomp_include.sh.in ucomp_include.sh @ONLY)
configure_file(ucomp.in ucomp @ONLY)
configure_file(ucomp_simulate_data.in ucomp_simulate_data @ONLY)
configure_file(ucomp_simulate_processing.in ucomp_simulate_processing @ONLY)

install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/ucomp_include.sh
                 ${CMAKE_CURRENT_BINARY_DIR}/ucomp
                 ${CMAKE_CURRENT_BINARY_DIR}/ucomp_simulate_data
                 ${CMAKE_CURRENT_BINARY_DIR}/ucomp_simulate_processing
        DESTINATION bin)

install(PROGRAMS ucomp_archive.sh
                 ucomp_calibrate.sh
                 ucomp_create_tables.sh
                 ucomp_eod.sh
                 ucomp_realtime.sh
                 ucomp_validate.sh
                 ucomp_validate_dates.sh
		 ucomp_make_t1log
        DESTINATION bin)
