; docformat = 'rst'


;= IDL_Object overloading operator implementations

;+
; Method called via `HELP`.
;
; :Returns:
;   string
;
; :Params:
;   varname : in, required, type=string
;     variable name
;-
function ucomp_file::_overloadHelp, varname
  compile_opt strictarr

  return, string(varname, $
                 'UCoMP', $
                 file_basename(self.raw_filename), $
                 self.n_extensions, $
                 self.wave_region, $
                 self.data_type, $
                 format='(%"%-15s %s  <%s, %d exts, %s nm, %s>")')
end


;+
; Method calls via `PRINT`.
;
; :Returns:
;   `strarr` or string
;-
function ucomp_file::_overloadPrint
  compile_opt strictarr

  if (self.n_extensions lt 1) then begin
    return, 'no extensions'
  endif

  self->getProperty, n_unique_wavelengths=n_unique_wavelengths

  output = strarr(self.n_extensions + 1L)
  output[0] = string(self.wave_region, $
                     self.data_type, $
                     self.n_extensions, $
                     n_unique_wavelengths, $
                     format='(%"UCoMP file: %s nm [%s] - %d exts (%d pts)")')
  for e = 1L, self.n_extensions do begin
    output[e] = string(e, (*self.wavelengths)[e - 1], format='(%"%d: %0.3f nm")')
  endfor

  return, transpose(output)
end


;= property access

;+
; Set property values.
;
; :Keywords:
;   quality_bitmask : in, optional, type=ulong
;     set to value to `or` with current value, values are::
;
;       0 - OK
;       1 - cover in
;       2 - moving optic elements, i.e., occulter, cal optics, etc.
;-
pro ucomp_file::setProperty, demodulated=demodulated, $
                             rotated=rotated, $
                             linearity_corrected=linearity_corrected, $
                             wrote_l1=wrote_l1, $
                             wrote_l2=wrote_l2, $
                             rcam_geometry=rcam_geometry, $
                             tcam_geometry=tcam_geometry, $
                             rcam_roughness=rcam_roughness, $
                             tcam_roughness=tcam_roughness, $
                             rcam_median_continuum=rcam_median_continuum, $
                             rcam_median_linecenter=rcam_median_linecenter, $
                             tcam_median_continuum=tcam_median_continuum, $
                             tcam_median_linecenter=tcam_median_linecenter, $
                             flat_rcam_median_linecenter=flat_rcam_median_linecenter, $
                             flat_rcam_median_continuum=flat_rcam_median_continuum, $
                             flat_tcam_median_linecenter=flat_tcam_median_linecenter, $
                             flat_tcam_median_continuum=flat_tcam_median_continuum, $
                             image_scale=image_scale, $
                             median_intensity=median_intensity, $
                             median_background=median_background, $
                             quality_bitmask=quality_bitmask, $
                             n_rcam_onband_saturated_pixels=n_rcam_onband_saturated_pixels, $
                             n_tcam_onband_saturated_pixels=n_tcam_onband_saturated_pixels, $
                             n_rcam_bkg_saturated_pixels=n_rcam_bkg_saturated_pixels, $
                             n_tcam_bkg_saturated_pixels=n_tcam_bkg_saturated_pixels, $
                             n_rcam_onband_nonlinear_pixels=n_rcam_onband_nonlinear_pixels, $
                             n_tcam_onband_nonlinear_pixels=n_tcam_onband_nonlinear_pixels, $
                             n_rcam_bkg_nonlinear_pixels=n_rcam_bkg_nonlinear_pixels, $
                             n_tcam_bkg_nonlinear_pixels=n_tcam_bkg_nonlinear_pixels, $
                             max_n_rcam_nonlinear_pixels_by_frame=max_n_rcam_nonlinear_pixels_by_frame, $
                             max_n_tcam_nonlinear_pixels_by_frame=max_n_tcam_nonlinear_pixels_by_frame, $
                             gbu=gbu, $
                             vcrosstalk_metric=vcrosstalk_metric, $
                             max_i_sigma=max_i_sigma, $
                             max_qu_sigma=max_qu_sigma, $
                             n_extensions=n_extensions, $
                             wavelengths=wavelengths, $
                             onband_indices=onband_indices, $
                             all_zero=all_zero
  compile_opt strictarr

  if (n_elements(demodulated)) then self.demodulated = demodulated
  if (n_elements(rotated)) then self.rotated = rotated
  if (n_elements(linearity_corrected)) then self.linearity_corrected = linearity_corrected
  if (n_elements(wrote_l1) gt 0L) then self.wrote_l1 = wrote_l1
  if (n_elements(wrote_l2)) then self.wrote_l2 = wrote_l2

  if (n_elements(rcam_geometry)) then self.rcam_geometry = rcam_geometry
  if (n_elements(tcam_geometry)) then self.tcam_geometry = tcam_geometry

  if (n_elements(rcam_roughness)) then self.rcam_roughness = rcam_roughness
  if (n_elements(tcam_roughness)) then self.tcam_roughness = tcam_roughness

  if (n_elements(rcam_median_continuum)) then self.rcam_median_continuum = rcam_median_continuum
  if (n_elements(rcam_median_linecenter)) then self.rcam_median_linecenter = rcam_median_linecenter
  if (n_elements(tcam_median_continuum)) then self.tcam_median_continuum = tcam_median_continuum
  if (n_elements(tcam_median_linecenter)) then self.tcam_median_linecenter = tcam_median_linecenter

  if (n_elements(flat_rcam_median_linecenter)) then self.flat_rcam_median_linecenter = flat_rcam_median_linecenter
  if (n_elements(flat_rcam_median_continuum)) then self.flat_rcam_median_continuum = flat_rcam_median_continuum
  if (n_elements(flat_tcam_median_linecenter)) then self.flat_tcam_median_linecenter = flat_tcam_median_linecenter
  if (n_elements(flat_tcam_median_continuum)) then self.flat_tcam_median_continuum = flat_tcam_median_continuum

  if (n_elements(image_scale)) then self.image_scale = image_scale

  if (n_elements(median_intensity)) then self.median_intensity = median_intensity
  if (n_elements(median_background)) then self.median_background = median_background

  if (n_elements(quality_bitmask) gt 0L) then begin
    self.quality_bitmask or= quality_bitmask
  endif

  if (n_elements(n_rcam_onband_saturated_pixels) gt 0L) then self.n_rcam_onband_saturated_pixels = n_rcam_onband_saturated_pixels
  if (n_elements(n_tcam_onband_saturated_pixels) gt 0L) then self.n_tcam_onband_saturated_pixels = n_tcam_onband_saturated_pixels
  if (n_elements(n_rcam_bkg_saturated_pixels) gt 0L) then self.n_rcam_bkg_saturated_pixels = n_rcam_bkg_saturated_pixels
  if (n_elements(n_tcam_bkg_saturated_pixels) gt 0L) then self.n_tcam_bkg_saturated_pixels = n_tcam_bkg_saturated_pixels
  if (n_elements(n_rcam_onband_nonlinear_pixels) gt 0L) then self.n_rcam_onband_nonlinear_pixels = n_rcam_onband_nonlinear_pixels
  if (n_elements(n_tcam_onband_nonlinear_pixels) gt 0L) then self.n_tcam_onband_nonlinear_pixels = n_tcam_onband_nonlinear_pixels
  if (n_elements(n_rcam_bkg_nonlinear_pixels) gt 0L) then self.n_rcam_bkg_nonlinear_pixels = n_rcam_bkg_nonlinear_pixels
  if (n_elements(n_tcam_bkg_nonlinear_pixels) gt 0L) then self.n_tcam_bkg_nonlinear_pixels = n_tcam_bkg_nonlinear_pixels

  if (n_elements(max_n_rcam_nonlinear_pixels_by_frame) gt 0L) then self.max_n_rcam_nonlinear_pixels_by_frame = max_n_rcam_nonlinear_pixels_by_frame
  if (n_elements(max_n_tcam_nonlinear_pixels_by_frame) gt 0L) then self.max_n_tcam_nonlinear_pixels_by_frame = max_n_tcam_nonlinear_pixels_by_frame

  if (n_elements(gbu) gt 0L) then self.gbu or= gbu
  if (n_elements(vcrosstalk_metric) gt 0L) then self.vcrosstalk_metric = vcrosstalk_metric
  if (n_elements(max_i_sigma) gt 0L) then self.max_i_sigma = max_i_sigma
  if (n_elements(max_qu_sigma) gt 0L) then self.max_qu_sigma = max_qu_sigma

  if (n_elements(n_extensions) gt 0L) then self.n_extensions = n_extensions
  if (n_elements(wavelengths) gt 0L) then *self.wavelengths = wavelengths
  if (n_elements(onband_indices) gt 0L) then *self.onband_indices = onband_indices

  if (n_elements(all_zero) gt 0L) then self.all_zero = all_zero
end


;+
; Find the index/indices of the center wavelength in the file.
;
; :Returns:
;   `lonarr` or `!null` if the center wavelength is not present
;-
function ucomp_file::get_center_wavelength_indices
  compile_opt strictarr

  wavelength_tolerance = 0.001
  center_wavelength = self.run->line(self.wave_region, 'center_wavelength')
  ext_indices = where(abs(*self.wavelengths - center_wavelength) lt wavelength_tolerance, /null)
  return, ext_indices
end


;+
; Get property values.
;-
pro ucomp_file::getProperty, run=run, $
                             raw_filename=raw_filename, $
                             l1_basename=l1_basename, $
                             l1_filename=l1_filename, $
                             l1_intensity_basename=l1_intensity_basename, $
                             intermediate_name=intermediate_name, $
                             l2_basename=l2_basename, $
                             demodulated=demodulated, $
                             rotated=rotated, $
                             linearity_corrected=linearity_corrected, $
                             wrote_l1=wrote_l1, $
                             wrote_l2=wrote_l2, $
                             hst_date=hst_date, $
                             hst_time=hst_time, $
                             ut_date=ut_date, $
                             ut_time=ut_time, $
                             obsday_hours=obsday_hours, $
                             date_obs=date_obs, $
                             date_begin=date_begin, $
                             date_end=date_end, $
                             julian_date=julian_date, $
                             carrington_rotation=carrington_rotation, $
                             p_angle=p_angle, $
                             b0=b0, $
                             semidiameter=semidiameter, $
                             distance_au=distance_au, $
                             true_dec=true_dec, $
                             wave_region=wave_region, $
                             center_wavelength=center_wavelength, $
                             data_type=data_type, $
                             obs_id_name=obs_id_name, $
                             obs_id_version=obs_id_version, $
                             obs_plan_name=obs_plan_name, $
                             obs_plan_version=obs_plan_version, $
                             program_name=program_name, $
                             exptime=exptime, $
                             gain_mode=gain_mode, $
                             nuc=nuc, $
                             pol_list=pol_list, $
                             focus=focus, $
                             o1focus=o1focus, $
                             nd=nd, $
                             contin=contin, $
                             n_extensions=n_extensions, $
                             wavelengths=wavelengths, $
                             n_unique_wavelengths=n_unique_wavelengths, $
                             unique_wavelengths=unique_wavelengths, $
                             onband_indices=onband_indices, $
                             median_intensity=median_intensity, $
                             median_background=median_background, $
                             quality_bitmask=quality_bitmask, $
                             n_rcam_onband_saturated_pixels=n_rcam_onband_saturated_pixels, $
                             n_tcam_onband_saturated_pixels=n_tcam_onband_saturated_pixels, $
                             n_rcam_bkg_saturated_pixels=n_rcam_bkg_saturated_pixels, $
                             n_tcam_bkg_saturated_pixels=n_tcam_bkg_saturated_pixels, $
                             n_rcam_onband_nonlinear_pixels=n_rcam_onband_nonlinear_pixels, $
                             n_tcam_onband_nonlinear_pixels=n_tcam_onband_nonlinear_pixels, $
                             n_rcam_bkg_nonlinear_pixels=n_rcam_bkg_nonlinear_pixels, $
                             n_tcam_bkg_nonlinear_pixels=n_tcam_bkg_nonlinear_pixels, $
                             max_n_rcam_nonlinear_pixels_by_frame=max_n_rcam_nonlinear_pixels_by_frame, $
                             max_n_tcam_nonlinear_pixels_by_frame=max_n_tcam_nonlinear_pixels_by_frame, $
                             gbu=gbu, $
                             ok=ok, $
                             good=good, $
                             vcrosstalk_metric=vcrosstalk_metric, $
                             max_i_sigma=max_i_sigma, $
                             max_qu_sigma=max_qu_sigma, $
                             wind_speed=wind_speed, $
                             wind_direction=wind_direction, $
                             occulter_in=occulter_in, $
                             occultrid=occultrid, $
                             o1id=o1id, $
                             occulter_x=occulter_x, $
                             occulter_y=occulter_y, $
                             obsswid=obsswid, $
                             cover_in=cover_in, $
                             darkshutter_in=darkshutter_in, $
                             opal_in=opal_in, $
                             caloptic_in=caloptic_in, $
                             polangle=polangle, $
                             retangle=retangle, $
                             dark_id=dark_id, $
                             rcamnuc=rcamnuc, $
                             tcamnuc=tcamnuc, $
                             rcam_roughness=rcam_roughness, $
                             tcam_roughness=tcam_roughness, $
                             rcam_median_continuum=rcam_median_continuum, $
                             rcam_median_linecenter=rcam_median_linecenter, $
                             tcam_median_continuum=tcam_median_continuum, $
                             tcam_median_linecenter=tcam_median_linecenter, $
                             flat_rcam_median_linecenter=flat_rcam_median_linecenter, $
                             flat_rcam_median_continuum=flat_rcam_median_continuum, $
                             flat_tcam_median_linecenter=flat_tcam_median_linecenter, $
                             flat_tcam_median_continuum=flat_tcam_median_continuum, $
                             rcam_geometry=rcam_geometry, $
                             tcam_geometry=tcam_geometry, $
                             image_scale=image_scale, $
                             occulter_radius=occulter_radius, $
                             post_angle=post_angle, $
                             t_base=t_base, $
                             t_lcvr1=t_lcvr1, $
                             t_lcvr2=t_lcvr2, $
                             t_lcvr3=t_lcvr3, $
                             t_lnb1=t_lnb1, $
                             t_mod=t_mod, $
                             t_lnb2=t_lnb2, $
                             t_lcvr4=t_lcvr4, $
                             t_lcvr5=t_lcvr5, $
                             t_rack=t_rack, $
                             tu_base=tu_base, $
                             tu_lcvr1=tu_lcvr1, $
                             tu_lcvr2=tu_lcvr2, $
                             tu_lcvr3=tu_lcvr3, $
                             tu_lnb1=tu_lnb1, $
                             tu_mod=tu_mod, $
                             tu_lnb2=tu_lnb2, $
                             tu_lcvr4=tu_lcvr4, $
                             tu_lcvr5=tu_lcvr5, $
                             tu_rack=tu_rack, $
                             tu_c0arr=tu_c0arr, $
                             tu_c0pcb=tu_c0pcb, $
                             tu_c1arr=tu_c1arr, $
                             tu_c1pcb=tu_c1pcb, $
                             numsum=numsum, $
                             n_repeats=n_repeats, $
                             v_lcvr3=v_lcvr3, $
                             sgs_dimv=sgs_dimv, $
                             sgs_dims=sgs_dims, $
                             sgs_scint=sgs_scint, $
                             sgs_sumv=sgs_sumv, $
                             sgs_sums=sgs_sums, $
                             sgs_loop=sgs_loop, $
                             sgs_rav=sgs_rav, $
                             sgs_ras=sgs_ras, $
                             sgs_razr=sgs_razr, $
                             sgs_decv=sgs_decv, $
                             sgs_decs=sgs_decs, $
                             sgs_deczr=sgs_deczr, $
                             all_zero=all_zero
  compile_opt strictarr

  if (arg_present(run)) then run = self.run

  ; for the file
  if (arg_present(raw_filename)) then raw_filename = self.raw_filename
  if (arg_present(l1_basename) || arg_present(l1_intensity_basename)) then begin
    name = n_elements(intermediate_name) eq 0L ? 'l1' : intermediate_name
    ; YYYYMMDD.HHMMSS.ucomp.WAVE.NAME.N.fts
    self->getProperty, n_unique_wavelengths=n_unique_wavelengths
    l1_basename = string(self.ut_date, $
                         self.ut_time, $
                         self.wave_region, $
                         name, $
                         n_unique_wavelengths, $
                         format='(%"%s.%s.ucomp.%s.%s.p%d.fts")')
    l1_intensity_basename = string(self.ut_date, $
                                   self.ut_time, $
                                   self.wave_region, $
                                   name, $
                                   n_unique_wavelengths, $
                                   format='(%"%s.%s.ucomp.%s.%s.p%d.intensity.fts")')
  endif
  if (arg_present(l1_filename)) then begin
    self->getProperty, l1_basename=l1_basename
    run = self.run
    l1_filename = filepath(l1_basename, $
                           subdir=[run.date, 'level1'], $
                           root=run->config('processing/basedir'))
  endif
  if (arg_present(l2_basename)) then begin
    l2_basename = string(self.ut_date, $
                         self.ut_time, $
                         self.wave_region, $
                         format='(%"%s.%s.ucomp.%s.l2.fts")')
  endif

  if (arg_present(demodulated)) then demodulated = self.demodulated
  if (arg_present(rotated)) then rotated = self.rotated
  if (arg_present(linearity_corrected)) then linearity_corrected = self.linearity_corrected
  if (arg_present(wrote_l1)) then wrote_l1 = self.wrote_l1
  if (arg_present(wrote_l2)) then wrote_l2 = self.wrote_l2

  if (arg_present(n_extensions)) then n_extensions = self.n_extensions

  if (arg_present(hst_date)) then hst_date = self.hst_date
  if (arg_present(hst_time)) then hst_time = self.hst_time
  if (arg_present(ut_date)) then ut_date = self.ut_date
  if (arg_present(ut_time)) then ut_time = self.ut_time
  if (arg_present(obsday_hours)) then obsday_hours = self.obsday_hours

  if (arg_present(date_obs)) then date_obs = self.date_obs
  if (arg_present(date_begin)) then date_begin = self.date_begin
  if (arg_present(date_end)) then date_end = self.date_end
  if (arg_present(julian_date)) then begin
    date_parts = long(ucomp_decompose_date(self.ut_date))
    time_parts = long(ucomp_decompose_time(self.ut_time))
    julian_date = julday(date_parts[1], date_parts[2], date_parts[0], $
                         time_parts[0], time_parts[1], time_parts[2])
  endif

  if (arg_present(carrington_rotation) $
        || arg_present(p_angle) $
        || arg_present(b0) $
        || arg_present(semidiameter) $
        || arg_present(dist_au) $
        || arg_present(true_dec)) then begin
    date_parts = ucomp_decompose_date(self.ut_date)
    hours = ucomp_decompose_time(self.ut_time, /float)
    sun, date_parts[0], date_parts[1], date_parts[2], hours, $
         carrington=carrington_rotation, $
         ;pa=p_angle, $
         lat0=b0, $
         sd=semidiameter, $
         dist=distance_au, $
         true_dec=true_dec

    ; TODO: remove after verification
    time_parts = long(ucomp_decompose_time(self.ut_time))
    julian_date = julday(date_parts[1], date_parts[2], date_parts[0], $
                         time_parts[0], time_parts[1], time_parts[2])
    ephem2, julian_date, sol_ra, sol_dec, b0_steve, p_angle
  endif

  if (arg_present(obs_id_name)) then obs_id_name = self.obs_id
  if (arg_present(obs_id_version)) then obs_id_version = self.obs_id_version
  if (arg_present(obs_plan_name)) then obs_plan_name = self.obs_plan
  if (arg_present(obs_plan_version)) then obs_plan_version = self.obs_plan_version
  if (arg_present(program_name)) then begin
    ; remove either .cbk or .ckb
    program_name = file_basename(self.obs_plan, '.cbk')
    program_name = file_basename(program_name, '.ckb')
    program_name = self.run->convert_program_name(program_name)
  endif

  if (arg_present(exptime)) then exptime = self.exptime
  if (arg_present(gain_mode)) then gain_mode = self.gain_mode
  if (arg_present(nuc)) then nuc = self.nuc
  if (arg_present(pol_list)) then pol_list = 'iquv'
  if (arg_present(nd)) then nd = self.nd

  if (arg_present(contin)) then contin = self.contin

  if (arg_present(wave_region)) then wave_region = self.wave_region
  if (arg_present(center_wavelength)) then begin
    if (self.wave_region eq '') then begin
      center_wavelength = 0.0
    endif else begin
      center_wavelength = self.run->line(self.wave_region, 'center_wavelength')
    endelse
  endif

  if (arg_present(data_type)) then data_type = self.data_type

  if (arg_present(median_intensity)) then median_intensity = self.median_intensity
  if (arg_present(median_background)) then median_background = self.median_background

  if (arg_present(quality_bitmask)) then quality_bitmask = self.quality_bitmask
  if (arg_present(n_rcam_onband_saturated_pixels)) then n_rcam_onband_saturated_pixels = self.n_rcam_onband_saturated_pixels
  if (arg_present(n_tcam_onband_saturated_pixels)) then n_tcam_onband_saturated_pixels = self.n_tcam_onband_saturated_pixels
  if (arg_present(n_rcam_bkg_saturated_pixels)) then n_rcam_bkg_saturated_pixels = self.n_rcam_bkg_saturated_pixels
  if (arg_present(n_tcam_bkg_saturated_pixels)) then n_tcam_bkg_saturated_pixels = self.n_tcam_bkg_saturated_pixels
  if (arg_present(n_rcam_onband_nonlinear_pixels)) then n_rcam_onband_nonlinear_pixels = self.n_rcam_onband_nonlinear_pixels
  if (arg_present(n_tcam_onband_nonlinear_pixels)) then n_tcam_onband_nonlinear_pixels = self.n_tcam_onband_nonlinear_pixels
  if (arg_present(n_rcam_bkg_nonlinear_pixels)) then n_rcam_bkg_nonlinear_pixels = self.n_rcam_bkg_nonlinear_pixels
  if (arg_present(n_tcam_bkg_nonlinear_pixels)) then n_tcam_bkg_nonlinear_pixels = self.n_tcam_bkg_nonlinear_pixels
  if (arg_present(max_n_rcam_nonlinear_pixels_by_frame)) then max_n_rcam_nonlinear_pixels_by_frame = self.max_n_rcam_nonlinear_pixels_by_frame
  if (arg_present(max_n_tcam_nonlinear_pixels_by_frame)) then max_n_tcam_nonlinear_pixels_by_frame = self.max_n_tcam_nonlinear_pixels_by_frame

  if (arg_present(gbu)) then gbu = self.gbu
  if (arg_present(ok)) then ok = self.quality_bitmask eq 0UL
  if (arg_present(good)) then good = (self.quality_bitmask eq 0UL) && (self.gbu eq 0UL)
  if (arg_present(vcrosstalk_metric)) then vcrosstalk_metric = self.vcrosstalk_metric
  if (arg_present(max_i_sigma)) then max_i_sigma = self.max_i_sigma
  if (arg_present(max_qu_sigma)) then max_qu_sigma = self.max_qu_sigma
  if (arg_present(wind_speed)) then wind_speed = self.wind_speed
  if (arg_present(wind_direction)) then wind_direction = self.wind_direction

  if (arg_present(focus)) then focus = self.focus
  if (arg_present(o1focus)) then o1focus = self.o1focus

  if (arg_present(occulter_in)) then occulter_in = self.occulter_in
  if (arg_present(occultrid)) then occultrid = self.occultrid
  if (arg_present(o1id)) then o1id = self.o1id

  if (arg_present(occulter_x)) then occulter_x = self.occulter_x
  if (arg_present(occulter_y)) then occulter_y = self.occulter_y

  if (arg_present(cover_in)) then cover_in = self.cover_in
  if (arg_present(darkshutter_in)) then darkshutter_in = self.darkshutter_in
  if (arg_present(opal_in)) then opal_in = self.opal_in
  if (arg_present(caloptic_in)) then caloptic_in = self.caloptic_in
  if (arg_present(polangle)) then polangle = self.polangle
  if (arg_present(retangle)) then retangle = self.retangle

  if (arg_present(dark_id)) then dark_id = self.dark_id
  if (arg_present(rcamnuc)) then rcamnuc = self.rcamnuc
  if (arg_present(tcamnuc)) then tcamnuc = self.tcamnuc

  if (arg_present(rcam_roughness)) then rcam_roughness = self.rcam_roughness
  if (arg_present(tcam_roughness)) then tcam_roughness = self.tcam_roughness

  if (arg_present(rcam_median_continuum)) then rcam_median_continuum = self.rcam_median_continuum
  if (arg_present(rcam_median_linecenter)) then rcam_median_linecenter = self.rcam_median_linecenter
  if (arg_present(tcam_median_continuum)) then tcam_median_continuum = self.tcam_median_continuum
  if (arg_present(tcam_median_linecenter)) then tcam_median_linecenter = self.tcam_median_linecenter

  if (arg_present(flat_rcam_median_linecenter)) then begin
    flat_rcam_median_linecenter = self.flat_rcam_median_linecenter
  endif
  if (arg_present(flat_rcam_median_continuum)) then begin
    flat_rcam_median_continuum = self.flat_rcam_median_continuum
  endif
  if (arg_present(flat_tcam_median_linecenter)) then begin
    flat_tcam_median_linecenter = self.flat_tcam_median_linecenter
  endif
  if (arg_present(flat_tcam_median_continuum)) then begin
    flat_tcam_median_continuum = self.flat_tcam_median_continuum
  endif

  if (arg_present(obsswid)) then obsswid = self.obsswid

  if (arg_present(rcam_geometry)) then rcam_geometry = self.rcam_geometry
  if (arg_present(tcam_geometry)) then tcam_geometry = self.tcam_geometry

  if (arg_present(image_scale)) then image_scale = self.image_scale

  if (arg_present(occulter_radius)) then begin
    self.rcam_geometry->getProperty, occulter_radius=rcam_radius
    self.tcam_geometry->getProperty, occulter_radius=tcam_radius
    occulter_radius = (rcam_radius + tcam_radius) / 2.0
  endif

  if (arg_present(post_angle)) then begin
    self.rcam_geometry->getProperty, post_angle=rcam_post_angle
    self.tcam_geometry->getProperty, post_angle=tcam_post_angle
    post_angle = mean([rcam_post_angle, tcam_post_angle], /nan)
  endif

  if (arg_present(t_base)) then t_base = self.t_base
  if (arg_present(t_lcvr1)) then t_lcvr1 = self.t_lcvr1
  if (arg_present(t_lcvr2)) then t_lcvr2 = self.t_lcvr2
  if (arg_present(t_lcvr3)) then t_lcvr3 = self.t_lcvr3
  if (arg_present(t_lnb1)) then t_lnb1 = self.t_lnb1
  if (arg_present(t_mod)) then t_mod = self.t_mod
  if (arg_present(t_lnb2)) then t_lnb2 = self.t_lnb2
  if (arg_present(t_lcvr4)) then t_lcvr4 = self.t_lcvr4
  if (arg_present(t_lcvr5)) then t_lcvr5 = self.t_lcvr5
  if (arg_present(t_rack)) then t_rack = self.t_rack
  if (arg_present(tu_base)) then tu_base = self.tu_base
  if (arg_present(tu_lcvr1)) then tu_lcvr1 = self.tu_lcvr1
  if (arg_present(tu_lcvr2)) then tu_lcvr2 = self.tu_lcvr2
  if (arg_present(tu_lcvr3)) then tu_lcvr3 = self.tu_lcvr3
  if (arg_present(tu_lnb1)) then tu_lnb1 = self.tu_lnb1
  if (arg_present(tu_mod)) then tu_mod = self.tu_mod
  if (arg_present(tu_lnb2)) then tu_lnb2 = self.tu_lnb2
  if (arg_present(tu_lcvr4)) then tu_lcvr4 = self.tu_lcvr4
  if (arg_present(tu_lcvr5)) then tu_lcvr5 = self.tu_lcvr5
  if (arg_present(tu_rack)) then tu_rack = self.tu_rack
  if (arg_present(tu_c0arr)) then tu_c0arr = self.tu_c0arr
  if (arg_present(tu_c0pcb)) then tu_c0pcb = self.tu_c0pcb
  if (arg_present(tu_c1arr)) then tu_c1arr = self.tu_c1arr
  if (arg_present(tu_c1pcb)) then tu_c1pcb = self.tu_c1pcb

  ; by extension
  if (arg_present(wavelengths)) then wavelengths = *self.wavelengths

  if (arg_present(n_unique_wavelengths)) then begin
    w = *self.wavelengths
    if (n_elements(w) eq 0L) then begin
      n_unique_wavelengths = 0L
    endif else begin
      n_unique_wavelengths = n_elements(uniq(w, sort(w)))
    endelse
  endif

  if (arg_present(unique_wavelengths)) then begin
    w = *self.wavelengths
    if (n_elements(w) eq 0L) then begin
      unique_wavelengths = !null
    endif else begin
      unique_wavelengths = w[uniq(w, sort(w))]
    endelse
  endif

  if (arg_present(onband_indices)) then onband_indices = *self.onband_indices

  if (arg_present(numsum)) then numsum = self.numsum
  if (arg_present(n_repeats)) then n_repeats = self.n_repeats

  if (arg_present(v_lcvr3)) then v_lcvr3 = *self.v_lcvr3

  if (arg_present(sgs_dimv)) then sgs_dimv = *self.sgs_dimv
  if (arg_present(sgs_dims)) then sgs_dims = *self.sgs_dims
  if (arg_present(sgs_scint)) then sgs_scint = *self.sgs_scint
  if (arg_present(sgs_sumv)) then sgs_sumv = *self.sgs_sumv
  if (arg_present(sgs_sums)) then sgs_sums = *self.sgs_sums
  if (arg_present(sgs_loop)) then sgs_loop = *self.sgs_loop
  if (arg_present(sgs_rav)) then sgs_rav = *self.sgs_rav
  if (arg_present(sgs_ras)) then sgs_ras = *self.sgs_ras
  if (arg_present(sgs_razr)) then sgs_razr = *self.sgs_razr
  if (arg_present(sgs_decv)) then sgs_decv = *self.sgs_decv
  if (arg_present(sgs_decs)) then sgs_decs = *self.sgs_decs
  if (arg_present(sgs_deczr)) then sgs_deczr = *self.sgs_deczr

  if (arg_present(all_zero)) then all_zero = self.all_zero
end


;= lifecycle methods

;+
; Extract datetime from raw file and convert to UT.
;-
pro ucomp_file::_extract_datetime
  compile_opt strictarr

  datetime = strmid(file_basename(self.raw_filename), 0, 15)
  self.ut_date = strmid(datetime, 0, 8)
  self.ut_time = strmid(datetime, 9, 6)
  ucomp_ut2hst, self.ut_date, self.ut_time, hst_date=hst_date, hst_time=hst_time
  self.hst_date = hst_date
  self.hst_time = hst_time
  hrs = [1.0, 1.0 / 60.0, 1.0 / 60.0 / 60.0]
  self.obsday_hours = total(float(ucomp_decompose_time(hst_time)) * hrs)
end


;+
; Update this `ucomp_file` object to a level 1 file.
;-
pro ucomp_file::_update_to_level1
  compile_opt strictarr

  self->getProperty, l1_basename=l1_basename
  l1_filename = filepath(l1_basename, $
                         subdir=[self.run.date, 'level1'], $
                         root=self.run->config('processing/basedir'))

  ucomp_read_l1_data, l1_filename, $
                      primary_header=primary_header, $
                      ext_headers=ext_headers, $
                      n_wavelengths=n_wavelengths

  ; find alignment
  center = [ucomp_getpar(primary_header, 'CRPIX1'), ucomp_getpar(primary_header, 'CRPIX2')] - 1.0
  geometry = ucomp_geometry(occulter_center=center, $
                            occulter_radius=ucomp_getpar(primary_header, 'RADIUS'), $
                            post_angle=ucomp_getpar(primary_header, 'POST_ANG'))
  self.rcam_geometry = geometry
  self.tcam_geometry = geometry

  ; continuum subtraction
  self.n_extensions = n_wavelengths
  wavelengths = fltarr(n_wavelengths)
  for e = 0L, n_wavelengths - 1L do begin
    wavelengths[e] = ucomp_getpar(ext_headers[e], 'WAVELNG')
  endfor
  *self.wavelengths = wavelengths
  *self.onband_indices = !null
end


;+
; Update the `ucomp_file` object to the given type.
;
; :Params:
;   type : in, required, type=string
;     type of file to update the file object to: "level1" or "level2"
;-
pro ucomp_file::update, type
  compile_opt strictarr

  case strlowcase(type) of
    'level1': self->_update_to_level1
    'level2':
  endcase
end


;+
; Inventory raw UCoMP file.
;-
pro ucomp_file::_inventory
  compile_opt strictarr
  on_error, 2

  datetime = strmid(file_basename(self.raw_filename), 0, 15)
  self.run->setProperty, datetime=datetime
  self.run->getProperty, logger_name=logger_name

  ucomp_read_raw_data, self.raw_filename, $
                       primary_header=primary_header, $
                       ext_headers=ext_headers, $
                       n_extensions=n_extensions, $
                       repair_routine=self.run->epoch('raw_data_repair_routine'), $
                       logger=logger_name

  self.n_extensions = n_extensions

  extension_header = ext_headers[0]

  filter = ucomp_getpar(primary_header, 'FILTER', found=found)
  if (n_elements(filter) gt 0L && filter ne '') then begin
    self.wave_region = strtrim(long(filter), 2)
  endif else begin
    self.wave_region = ''
  endelse

  if (n_elements(extension_header) gt 0L) then begin
    self.data_type = ucomp_getpar(extension_header, 'DATATYPE', found=found)
  endif

  ; darks don't have a wave_region
  if (self.data_type eq 'dark') then self.wave_region = ''

  self.date_obs  = ucomp_getpar(primary_header, 'DATE-OBS', found=found)

  self.obs_id = ucomp_getpar(primary_header, 'OBS_ID', found=found)
  self.obs_id_version = ucomp_getpar(primary_header, 'OBS_IDVE', found=found)
  self.obs_plan = ucomp_getpar(primary_header, 'OBS_PLAN', found=found)
  self.obs_plan_version = ucomp_getpar(primary_header, 'OBS_PLVE', found=found)

  if (n_elements(extension_header) gt 0L) then begin
    self.cover_in = ucomp_getpar(extension_header, 'COVER', found=found) eq 'in'
    self.darkshutter_in = ucomp_getpar(extension_header, 'DARKSHUT', found=found) eq 'in'
    self.occulter_in = ucomp_getpar(extension_header, 'OCCLTR', found=found) eq 'in'
    self.occultrid = ucomp_getpar(primary_header, 'OCCLTRID', found=found)
    self.o1id = ucomp_getpar(primary_header, 'O1ID', found=found)
  endif

  if (self.run->epoch('use_occltr_position')) then begin
    self.occulter_x = ucomp_getpar(primary_header, 'OCCLTR-X', /float)
    self.occulter_y = ucomp_getpar(primary_header, 'OCCLTR-Y', /float)
  endif else begin
    self.occulter_x = self.run->epoch('occltr_x')
    self.occulter_y = self.run->epoch('occltr_y')
  endelse

  self.dark_id = ucomp_getpar(primary_header, 'DARKID')
  self.rcamnuc = ucomp_getpar(primary_header, 'RCAMNUC')
  self.tcamnuc = ucomp_getpar(primary_header, 'TCAMNUC')

  if (n_elements(extension_header) gt 0L) then begin
    self.opal_in = strlowcase(ucomp_getpar(extension_header, 'DIFFUSR', found=found)) eq 'in'
    self.caloptic_in = strlowcase(ucomp_getpar(extension_header, 'CALOPTIC', found=found)) eq 'in'
    self.polangle = ucomp_getpar(extension_header, 'POLANGLE', /float, found=found)
    self.retangle = ucomp_getpar(extension_header, 'RETANGLE', /float, found=found)
  endif

  self.obsswid = ucomp_getpar(primary_header, 'OBSSWID', found=found)

  self.gain_mode = strtrim(strlowcase(ucomp_getpar(primary_header, 'GAIN', found=found)), 2)

  rcam_nuc = strtrim(ucomp_getpar(primary_header, 'RCAMNUC', found=found), 2)
  tcam_nuc = strtrim(ucomp_getpar(primary_header, 'TCAMNUC', found=found), 2)
  if (rcam_nuc ne tcam_nuc) then begin
    self.nuc = rcam_nuc + '/' + tcam_nuc
  endif else self.nuc = rcam_nuc

  ; TODO: enter this from the headers
  self.nd = 0L

  self.t_base   = ucomp_getpar(primary_header, 'T_BASE', /float, found=found)
  self.t_lcvr1  = ucomp_getpar(primary_header, 'T_LCVR1', /float, found=found)
  self.t_lcvr2  = ucomp_getpar(primary_header, 'T_LCVR2', /float, found=found)
  self.t_lcvr3  = ucomp_getpar(primary_header, 'T_LCVR3', /float, found=found)
  self.t_lnb1   = ucomp_getpar(primary_header, 'T_LNB1', /float, found=found)
  self.t_mod    = ucomp_getpar(primary_header, 'T_MOD', /float, found=found)
  self.t_lnb2   = ucomp_getpar(primary_header, 'T_LNB2', /float, found=found)
  self.t_lcvr4  = ucomp_getpar(primary_header, 'T_LCVR4', /float, found=found)
  self.t_lcvr5  = ucomp_getpar(primary_header, 'T_LCVR5', /float, found=found)
  self.t_rack   = ucomp_getpar(primary_header, 'T_RACK', /float, found=found)
  self.tu_base  = ucomp_getpar(primary_header, 'TU_BASE', /float, found=found)
  self.tu_lcvr1 = ucomp_getpar(primary_header, 'TU_LCVR1', /float, found=found)
  self.tu_lcvr2 = ucomp_getpar(primary_header, 'TU_LCVR2', /float, found=found)
  self.tu_lcvr3 = ucomp_getpar(primary_header, 'TU_LCVR3', /float, found=found)
  self.tu_lnb1  = ucomp_getpar(primary_header, 'TU_LNB1', /float, found=found)
  self.tu_mod   = ucomp_getpar(primary_header, 'TU_MOD', /float, found=found)
  self.tu_lnb2  = ucomp_getpar(primary_header, 'TU_LNB2', /float, found=found)
  self.tu_lcvr4 = ucomp_getpar(primary_header, 'TU_LCVR4', /float, found=found)
  self.tu_lcvr5 = ucomp_getpar(primary_header, 'TU_LCVR5', /float, found=found)
  self.tu_rack  = ucomp_getpar(primary_header, 'TU_RACK', /float, found=found)
  self.tu_c0arr = ucomp_getpar(primary_header, 'TU_C0ARR', /float, found=found)
  self.tu_c0pcb = ucomp_getpar(primary_header, 'TU_C0PCB', /float, found=found)
  self.tu_c1arr = ucomp_getpar(primary_header, 'TU_C1ARR', /float, found=found)
  self.tu_c1pcb = ucomp_getpar(primary_header, 'TU_C1PCB', /float, found=found)

  self.wind_speed     = ucomp_getpar(primary_header, 'WNDSPD', /float, found=found)
  self.wind_direction = ucomp_getpar(primary_header, 'WNDDIR', /float, found=found)

  if (n_elements(extension_header) gt 0L) then begin
    self.numsum  = ucomp_getpar(extension_header, 'NUMSUM', found=found)
    self.exptime = ucomp_getpar(extension_header, 'EXPTIME', /float, found=found)
    self.o1focus = ucomp_getpar(extension_header, 'O1FOCUS', /float, found=found)
  endif

  ; inventory extensions for things that vary by extension
  moving_parts = 0B

  ; allocate inventory variables
  if (self.n_extensions gt 0L) then begin
    *self.wavelengths    = fltarr(self.n_extensions)
    *self.onband_indices = lonarr(self.n_extensions)

    *self.v_lcvr3        = fltarr(self.n_extensions)

    *self.sgs_dimv       = fltarr(self.n_extensions)
    *self.sgs_dims       = fltarr(self.n_extensions)
    *self.sgs_scint      = fltarr(self.n_extensions)
    *self.sgs_sumv       = fltarr(self.n_extensions)
    *self.sgs_sums       = fltarr(self.n_extensions)
    *self.sgs_loop       = fltarr(self.n_extensions)
    *self.sgs_rav        = fltarr(self.n_extensions)
    *self.sgs_ras        = fltarr(self.n_extensions)
    *self.sgs_razr       = fltarr(self.n_extensions)
    *self.sgs_decv       = fltarr(self.n_extensions)
    *self.sgs_decs       = fltarr(self.n_extensions)
    *self.sgs_deczr      = fltarr(self.n_extensions)
  endif

  self.contin = ucomp_getpar(ext_headers[0], 'CONTIN')
  for e = 1L, self.n_extensions do begin
    extension_header = ext_headers[e - 1L]

    if (self.contin ne ucomp_getpar(extension_header, 'CONTIN')) then begin
      self.contin = 'multiple'
    endif

    if (e eq 1) then self.date_begin = ucomp_getpar(extension_header, 'DATE-BEG')
    if (e eq self.n_extensions) then self.date_end = ucomp_getpar(extension_header, 'DATE-BEG')

    (*self.v_lcvr3)[e - 1] = ucomp_getpar(extension_header, 'V_LCVR3', /float, found=found)

    (*self.wavelengths)[e - 1] = ucomp_getpar(extension_header, 'WAVELNG', /float, found=found)
    (*self.onband_indices)[e - 1] = ucomp_getpar(extension_header, 'ONBAND', found=found) eq 'tcam'

    (*self.sgs_dimv)[e - 1]  = ucomp_getpar(extension_header, 'SGSDIMV', /float, found=found)
    (*self.sgs_dims)[e - 1]  = ucomp_getpar(extension_header, 'SGSDIMS', /float, found=found)
    (*self.sgs_scint)[e - 1] = ucomp_getpar(extension_header, 'SGSSCINT', /float, found=found)
    (*self.sgs_sumv)[e - 1]  = ucomp_getpar(extension_header, 'SGSSUMV', /float, found=found)
    (*self.sgs_sums)[e - 1]  = ucomp_getpar(extension_header, 'SGSSUMS', /float, found=found)
    (*self.sgs_loop)[e - 1]  = ucomp_getpar(extension_header, 'SGSLOOP', /float, found=found)
    (*self.sgs_rav)[e - 1]   = ucomp_getpar(extension_header, 'SGSRAV', /float, found=found)
    (*self.sgs_ras)[e - 1]   = ucomp_getpar(extension_header, 'SGSRAS', /float, found=found)
    (*self.sgs_razr)[e - 1]  = ucomp_getpar(extension_header, 'SGSRAZR', /float, found=found)
    (*self.sgs_decv)[e - 1]  = ucomp_getpar(extension_header, 'SGSDECV', /float, found=found)
    (*self.sgs_decs)[e - 1]  = ucomp_getpar(extension_header, 'SGSDECS', /float, found=found)
    (*self.sgs_deczr)[e - 1] = ucomp_getpar(extension_header, 'SGSDECZR', /float, found=found)
  endfor

  if (self.n_extensions gt 0L) then begin
    self->getProperty, n_unique_wavelengths=n_unique_wavelengths
    n_cameras = 2L   ; number of values that ONBAND can take
    self.n_repeats = self.n_extensions / n_unique_wavelengths / n_cameras
  endif

  obj_destroy, ext_headers
end


;+
; Free resources.
;-
pro ucomp_file::cleanup
  compile_opt strictarr

  ptr_free, self.wavelengths, self.onband_indices
  ptr_free, self.v_lcvr3
  ptr_free, self.sgs_dimv, self.sgs_dims, self.sgs_scint, self.sgs_sumv, $
            self.sgs_sums, self.sgs_loop, self.sgs_rav, self.sgs_ras, $
            self.sgs_razr, self.sgs_decv, self.sgs_decs, self.sgs_deczr
  obj_destroy, [self.rcam_geometry, self.tcam_geometry]
end


;+
; Initialize UCoMP file object.
;
; :Returns:
;   1 for success, 0 otherwise
;
; :Params:
;   raw_filename : in, required, type=str
;     filename of raw UCoMP file
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_file::init, raw_filename, run=run
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    msg = strtrim(strmid(!error_state.msg, strpos(!error_state.msg, ':') + 1), 2)
    mg_log, '%s', msg, name=run.logger_name, /error
    return, 0
  endif

  self.raw_filename = raw_filename
  self.run = run

  self->_extract_datetime

  self.data_type = 'unk'

  self.median_intensity  = !values.f_nan
  self.median_background = !values.f_nan
  self.vcrosstalk_metric = !values.f_nan
  self.max_i_sigma       = !values.f_nan
  self.max_qu_sigma      = !values.f_nan

  self.rcam_roughness = !values.f_nan
  self.tcam_roughness = !values.f_nan

  self.rcam_median_continuum  = !values.f_nan
  self.rcam_median_linecenter = !values.f_nan
  self.tcam_median_continuum  = !values.f_nan
  self.tcam_median_linecenter = !values.f_nan

  self.image_scale = !values.f_nan

  ; allocate inventory variables for extensions
  self.v_lcvr3 = ptr_new(/allocate_heap)

  self.wavelengths = ptr_new(/allocate_heap)
  self.onband_indices = ptr_new(/allocate_heap)

  self.sgs_dimv  = ptr_new(/allocate_heap)
  self.sgs_dims  = ptr_new(/allocate_heap)
  self.sgs_scint = ptr_new(/allocate_heap)
  self.sgs_sumv  = ptr_new(/allocate_heap)
  self.sgs_sums  = ptr_new(/allocate_heap)
  self.sgs_loop  = ptr_new(/allocate_heap)
  self.sgs_rav   = ptr_new(/allocate_heap)
  self.sgs_ras   = ptr_new(/allocate_heap)
  self.sgs_razr  = ptr_new(/allocate_heap)
  self.sgs_decv  = ptr_new(/allocate_heap)
  self.sgs_decs  = ptr_new(/allocate_heap)
  self.sgs_deczr = ptr_new(/allocate_heap)

  self->_inventory

  return, 1
end


;+
; Define instance variables.
;-
pro ucomp_file__define
  compile_opt strictarr

  !null = {ucomp_file, inherits IDL_Object, $
           raw_filename                         : '', $

           run                                  : obj_new(), $

           demodulated                          : 0B, $
           rotated                              : 0B, $
           linearity_corrected                  : 0B, $
           wrote_l1                             : 0B, $
           wrote_l2                             : 0B, $

           hst_date                             : '', $
           hst_time                             : '', $
           ut_date                              : '', $
           ut_time                              : '', $
           obsday_hours                         : 0.0, $
           date_obs                             : '', $
           date_begin                           : '', $
           date_end                             : '', $

           n_extensions                         : 0L, $
           n_repeats                            : 0L, $

           wave_region                          : '', $
           data_type                            : '', $
           obs_id                               : '', $
           obs_id_version                       : '', $
           obs_plan                             : '', $
           obs_plan_version                     : '', $
           exptime                              : 0.0, $
           gain_mode                            : '', $
           nuc                                  : '', $
           numsum                               : 0L, $

           focus                                : 0.0, $
           o1focus                              : 0.0, $

           nd                                   : 0L, $
           occulter_in                          : 0B, $
           occultrid                            : '', $
           o1id                                 : '', $
           cover_in                             : 0B, $
           darkshutter_in                       : 0B, $
           opal_in                              : 0B, $
           caloptic_in                          : 0B, $
           polangle                             : 0.0, $
           retangle                             : 0.0, $

           dark_id                              : '', $
           rcamnuc                              : '', $
           tcamnuc                              : '', $

           contin                               : '', $

           obsswid                              : '', $

           median_intensity                     : 0.0, $
           median_background                    : 0.0, $

           ; for flats only
           tcam_roughness                       : 0.0, $
           rcam_roughness                       : 0.0, $

           ; for darks, flats, cals only
           rcam_median_continuum                : 0.0, $
           rcam_median_linecenter               : 0.0, $
           tcam_median_continuum                : 0.0, $
           tcam_median_linecenter               : 0.0, $

           flat_rcam_median_linecenter          : 0.0, $
           flat_rcam_median_continuum           : 0.0, $
           flat_tcam_median_linecenter          : 0.0, $
           flat_tcam_median_continuum           : 0.0, $

           occulter_x                           : 0.0, $
           occulter_y                           : 0.0, $
           rcam_geometry                        : obj_new(), $
           tcam_geometry                        : obj_new(), $

           image_scale                          : 0.0, $

           t_base                               : 0.0, $
           t_lcvr1                              : 0.0, $
           t_lcvr2                              : 0.0, $
           t_lcvr3                              : 0.0, $
           t_lnb1                               : 0.0, $
           t_mod                                : 0.0, $
           t_lnb2                               : 0.0, $
           t_lcvr4                              : 0.0, $
           t_lcvr5                              : 0.0, $
           t_rack                               : 0.0, $
           tu_base                              : 0.0, $
           tu_lcvr1                             : 0.0, $
           tu_lcvr2                             : 0.0, $
           tu_lcvr3                             : 0.0, $
           tu_lnb1                              : 0.0, $
           tu_mod                               : 0.0, $
           tu_lnb2                              : 0.0, $
           tu_lcvr4                             : 0.0, $
           tu_lcvr5                             : 0.0, $
           tu_rack                              : 0.0, $
           tu_c0arr                             : 0.0, $
           tu_c0pcb                             : 0.0, $
           tu_c1arr                             : 0.0, $
           tu_c1pcb                             : 0.0, $

           v_lcvr3                              : ptr_new(), $

           wavelengths                          : ptr_new(), $
           onband_indices                       : ptr_new(), $

           sgs_dimv                             : ptr_new(), $
           sgs_dims                             : ptr_new(), $
           sgs_scint                            : ptr_new(), $
           sgs_sumv                             : ptr_new(), $
           sgs_sums                             : ptr_new(), $
           sgs_loop                             : ptr_new(), $
           sgs_rav                              : ptr_new(), $
           sgs_ras                              : ptr_new(), $
           sgs_razr                             : ptr_new(), $
           sgs_decv                             : ptr_new(), $
           sgs_decs                             : ptr_new(), $
           sgs_deczr                            : ptr_new(), $

           quality_bitmask                      : 0UL, $

           n_rcam_onband_saturated_pixels       : 0UL, $
           n_tcam_onband_saturated_pixels       : 0UL, $
           n_rcam_bkg_saturated_pixels          : 0UL, $
           n_tcam_bkg_saturated_pixels          : 0UL, $
           n_rcam_onband_nonlinear_pixels       : 0UL, $
           n_tcam_onband_nonlinear_pixels       : 0UL, $
           n_rcam_bkg_nonlinear_pixels          : 0UL, $
           n_tcam_bkg_nonlinear_pixels          : 0UL, $

           max_n_rcam_nonlinear_pixels_by_frame : 0UL, $
           max_n_tcam_nonlinear_pixels_by_frame : 0UL, $

           gbu                                  : 0UL, $
           processed                            : 0B, $
           vcrosstalk_metric                    : 0.0, $
           max_i_sigma                          : 0.0, $
           max_qu_sigma                         : 0.0, $
           wind_speed                           : 0.0, $
           wind_direction                       : 0.0, $

           all_zero                             : 0B $
          }
end
