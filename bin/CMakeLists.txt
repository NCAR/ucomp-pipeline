file(READ ../resource/program_names.cfg PROGRAM_TABLE)

configure_file(ucomp_include.sh.in ucomp_include.sh @ONLY)
configure_file(ucomp.in ucomp @ONLY)
configure_file(ucompd.in ucompd @ONLY)
configure_file(ucomp_nightly.sh.in ucomp_nightly.sh @ONLY)
configure_file(ucomp_regression.sh.in ucomp_regression.sh @ONLY)
configure_file(ucomp_verify.sh.in ucomp_verify.sh @ONLY)
configure_file(ucomp_verify_dates.sh.in ucomp_verify_dates.sh @ONLY)

configure_file(ucomp_simulate_data.in ucomp_simulate_data.sh @ONLY)
configure_file(ucomp_simulate_processing.in ucomp_simulate_processing.sh @ONLY)


install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/ucomp
                 ${CMAKE_CURRENT_BINARY_DIR}/ucompd
                 ${CMAKE_CURRENT_BINARY_DIR}/ucomp_nightly.sh
                 ${CMAKE_CURRENT_BINARY_DIR}/ucomp_regression.sh
                 ${CMAKE_CURRENT_BINARY_DIR}/ucomp_simulate_data.sh
                 ${CMAKE_CURRENT_BINARY_DIR}/ucomp_simulate_processing.sh
                 ${CMAKE_CURRENT_BINARY_DIR}/ucomp_verify.sh
		 ${CMAKE_CURRENT_BINARY_DIR}/ucomp_verify_dates.sh
        DESTINATION bin)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/ucomp_include.sh
        DESTINATION bin)

install(PROGRAMS ucomp_create_tables.sh
                 ucomp_env.sh
                 ucomp_eod_check_today.sh
		 ucomp_eod_today.sh
                 ucomp_realtime_today.sh
                 ucomp_script.sh
                 ucomp_validate_files.sh
                 ucomp_make_t1log
        DESTINATION bin)

install(FILES ucomp_parse_args.sh
              ucomp_regression_include.sh
              ucomp-completion.bash
        DESTINATION bin)
