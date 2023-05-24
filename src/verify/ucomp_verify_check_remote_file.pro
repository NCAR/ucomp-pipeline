; docformat = 'rst'

;+
; Check a file existence and properties on a remote server compared to the
; local file.
;
; :Returns:
;   `0UL` if no error, otherwise an error occurred (`1UL` indicates local file
;   not found, `2UL` indicates a problem checking remote file, `4UL` indicates
;   a bad format for `ls` output on remote server, `8UL` indicates bad remote
;   permissions, `16UL` indicates bad remote group owner, and `32UL` indicates
;   bad remote file size)
;
; :Params:
;   basename : in, required, type=string
;     basename of file to be checked
;   local_dir : in, required, type=string
;     local directory for file to be checked
;   remote_server : in, required, type=string
;     server name for remote location of file
;   remote_dir : in, required, type=string
;     remote directory for file
;   ssh_key : in, optional, type=string
;     full path to SSH key to use when connecting to remote server
;
; :Keywords:
;   logger_name : in, optional, type=string
;     name of logger to send log messages to
;-
function ucomp_verify_check_remote_file, basename, $
                                         local_dir, $
                                         remote_server, $
                                         remote_dir, $
                                         ssh_key, $
                                         logger_name=logger_name
  compile_opt strictarr

  local_filename = filepath(basename, root=local_dir)
  if (~file_test(local_filename, /regular)) then begin
    mg_log, '%s not found locally', basename, name=logger_name, /warn
    return, 1UL
  endif

  local_filesize = mg_filesize(local_filename)
  remote_filename = filepath(basename, root=remote_dir)
  ssh_options = ''
  if (n_elements(ssh_key) gt 0L) then ssh_options += string(ssh_key, format='(%"-i %s")')

  ssh_cmd = string(ssh_options, $
                   remote_server, $
                   remote_filename, $
                   format='(%"ssh %s %s ls -l %s")')
  spawn, ssh_cmd, ssh_output, ssh_error, exit_status=ssh_status
  if (ssh_status ne 0L) then begin
    mg_log, 'problem checking file %s:%s', $
            remote_server, $
            remote_filename, $
            name=logger_name, /error
    mg_log, 'command: %s', ssh_cmd, name=logger_name, /error
    mg_log, '%s', strjoin(ssh_error, ' '), name=logger_name, /error
    return, 2UL
  endif

  tokens = strsplit(ssh_output[0], /extract, count=n_tokens)
  if (n_tokens ne 9) then begin
    mg_log, 'bad format for ls -l output', name=logger_name, /error
    mg_log, 'output: %s', output[0], name=logger_name, /debug
    return, 4UL
  endif

  permissions = tokens[0]
  group = tokens[3]
  remote_filesize = long64(tokens[4])

  if (strmid(permissions, 0, 10) ne '-rw-rw----') then begin
    mg_log, 'bad remote permissions: %s', permissions, name=logger_name, /warn
    return, 8UL
  endif

  if (group ne 'cordyn') then begin
    mg_log, 'bad remote group: %s', group, name=logger_name, /warn
    return, 16UL
  endif

  if (remote_filesize ne local_filesize) then begin
    mg_log, 'non-matching file sizes (local: %s B, remote %s B)', $
            mg_float2str(local_filesize, places_sep=','), $
            mg_float2str(remote_filesize, places_sep=','), $
            name=logger_name, /warn
    return, 32UL
  endif

  mg_log, '%s matches on remote server', basename, name=logger_name, /info
  return, 0UL
end
