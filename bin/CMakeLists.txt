configure_file(ucomp_verify_dates.sh.in ucomp_verify_dates.sh @ONLY)
configure_file(ucomp_process.sh.in ucomp_process.sh @ONLY)
configure_file(ucomp_process_range.sh.in ucomp_process_range.sh @ONLY)
configure_file(ucomp.in ucomp @ONLY)

install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/ucomp_verify_dates.sh
                 ${CMAKE_CURRENT_BINARY_DIR}/ucomp_process.sh
                 ${CMAKE_CURRENT_BINARY_DIR}/ucomp_process_range.sh
                 ${CMAKE_CURRENT_BINARY_DIR}/ucomp
        DESTINATION bin)

install(PROGRAMS ucomp_verify.sh
                 ucomp_get_hostname.sh
                 ucomp_mail_results.sh
        DESTINATION bin)
