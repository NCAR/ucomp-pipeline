pro host_to_ieee, data, IDLTYPE = idltype
;+
; NAME:
;	HOST_TO_IEEE
; PURPOSE:
;	To translate an IDL variable from IEEE-754 representation (as used, for
;	example, in FITS data ), into the host machine architecture.
;
; CALLING SEQUENCE:
;	HOST_TO_IEEE, data, [ IDLTYPE = , ]
;
; INPUT-OUTPUT PARAMETERS:
;	data - any IDL variable, scalar or vector.   It will be modified by
;		HOST_TO_IEEE to convert from host to IEEE representation.  Byte
;		and string variables are returned by HOST_TO_IEEE unchanged
;
; OPTIONAL KEYWORD INPUTS:
;	IDLTYPE - scalar integer (1-7) specifying the IDL datatype according
;		to the code given by the SIZE function.      This keyword
;		will usually be used when suppying a byte array that needs
;		to be interpreted as another data type (e.g. FLOAT).
;
; EXAMPLE:
;	Suppose FITARR is a 2880 element byte array to be converted to a FITS
;	record and interpreted a FLOAT data.
;
;	IDL> host_to_ieee, FITARR, IDLTYPE = 4
;
; METHOD:
;	The BYTEORDER procedure is called with the appropiate keywords
;
; RESTRICTION:
;	Will run *much* faster for floating or double precision if the IDL
;	version is since 2.2.2 when the /FTOXDR keyword  became available to
;	BYTEORDER.
;	However, HOST_TO_IEEE should still work in earlier versions of IDL
;	Note that in V3.0.0 there is a bug in the /DTOXDR keyword for
;	BYTEORDER on DecStations so HOST_TO_IEEE has a workaround.
;
; MODIFICATION HISTORY:
;	Adapted from CONV_UNIX_VAX, W. Landsman   Hughes/STX    January, 1992
;	Fixed Case statement for Float and Double      September, 1992
;	Workaround for /DTOXDR on DecStations          January, 1993
;-
 On_error,2

 if N_params() EQ 0 then begin
    print,'Syntax - HOST_TO_IEEE, data, [IDLTYPE = ]
    return
 endif

 npts = N_elements( data )
 if npts EQ 0 then $
     message,'ERROR - IDL data variable (first parameter) not defined'

 sz = size(data)
 if not keyword_set( idltype) then idltype = sz( sz(0)+1)

 case idltype of

      1: return                             ;byte

      2: byteorder, data, /HTONS            ;integer

      3: byteorder, data, /HTONL            ;long

      4: begin                              ;float
         if since_version('2.2.2') then byteorder, data, /FTOXDR $
            else begin
            case !VERSION.OS of
            'vms': data = conv_vax_unix(data,target = 'sparc')
            'mipsel': byteorder,data,/LSWAP
            '386': byteorder,data,/LSWAP
            '386i': byteorder,data,/LSWAP
            else:
            endcase
         endelse
         end

      5: begin                          ;double

            if !VERSION.ARCH NE 'mipsel' then begin

                if since_version('2.2.2') then $
                          byteorder, data, /DTOXDR  else $
                          conv_unix_vax, data, target = 'sparc'

            endif else begin

                     if !VERSION.RELEASE NE '3.0.0' then begin

                          byteorder, data, /DTOXDR

                    endif else begin

                    dtype = sz( sz(0) + 1)
                    if ( dtype EQ 5 ) then data = byte(data, 0, npts*8) $
                                      else npts = npts/8
                    data = reform( data, 8 , npts ,/OVER)
                    data = rotate( data, 5)
                    if ( dtype EQ 5 ) then data = double(data, 0, npts)
                    data = reform( data, sz(1:sz(0)), /OVER )

                    endelse

             endelse
         end

      6: BEGIN                              ;complex
           fdata = float(data)
           byteorder, fdata, /FTOXDR
           idata = imaginary( temporary(data) )
           byteorder, idata, /FTOXDR
           data = complex( fdata, idata )
         END

      7: return                             ;string

       8: BEGIN				    ;structure

	Ntag = N_tags( data )

	for t=0,Ntag-1 do  begin
          temp = data.(t)
          host_to_ieee, temp
          data.(t) = temp
        endfor

       END
 ENDCASE

 return
 end
