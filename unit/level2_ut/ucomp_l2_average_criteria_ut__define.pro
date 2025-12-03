; docformat = 'rst'

function ucomp_l2_average_criteria_ut::test_toofew
  compile_opt strictarr

  program_files = [{obsday_hours: 0.75}]
  average_files = ucomp_l2_average_criteria(program_files, $
                                            'program name', $
                                            count=count, $
                                            max_length=30.0)

  assert, count eq 1, 'incorrect reported number of files to average: %d', count

  n_program_files = n_elements(average_files)
  assert, n_program_files eq 1, 'incorrect number of files to average: %d', n_program_files

  return, 1
end


function ucomp_l2_average_criteria_ut::test_basic
  compile_opt strictarr

  program_files = [{obsday_hours: 0.75}, $
                   {obsday_hours: 0.755}, $
                   {obsday_hours: 0.765}]
  average_files = ucomp_l2_average_criteria(program_files, $
                                            'program name', $
                                            count=count, $
                                            max_length=30.0)

  assert, count eq 2, 'incorrect reported number of files to average: %d', count

  n_program_files = n_elements(average_files)
  assert, n_program_files eq 2, 'incorrect number of files to average: %d', n_program_files

  return, 1
end


function ucomp_l2_average_criteria_ut::test_basic
  compile_opt strictarr

  program_files = [{obsday_hours: 0.75}, $
                   {obsday_hours: 0.755}, $
                   {obsday_hours: 0.765}, $
                   {obsday_hours: 0.77}]
  average_files = ucomp_l2_average_criteria(program_files, $
                                            'program name', $
                                            count=count, $
                                            max_length=30.0)

  assert, count eq 2, 'incorrect reported number of files to average: %d', count

  n_program_files = n_elements(average_files)
  assert, n_program_files eq 2, 'incorrect number of files to average: %d', n_program_files

  return, 1
end


function ucomp_l2_average_criteria_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_l2_average_criteria'], $
                           /is_function

  return, 1
end

pro ucomp_l2_average_criteria_ut__define
  compile_opt strictarr

  define = {ucomp_l2_average_criteria_ut, inherits UCoMPutTestCase}
end
