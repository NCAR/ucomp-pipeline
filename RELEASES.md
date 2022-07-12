0.1.0 [Sep 23, 2021]
  create inventory files
  create master dark file
  create master flat file
  average data in science files with the same wavelength, gain mode, etc.
  apply dark/flat correction
  demodulation
  apply distortion
  continuum subtraction
  combine cameras
0.1.1 [Sep 28, 2021]
  promote issues in observing plan that prevent calibration to errors from warnings
  C implementation of demodulation
  handle epochs with no OCCLTR-{X,Y} values in FITS headers
0.1.2 [Oct 5, 2021]
  option to write only center wavelength intensity or all extensions
  use non-matching exposure time flats
  fix hot pixels
0.1.3 [Oct 5, 2021]
  fixes for hot pixel correction
0.1.4 [Oct 8, 2021]
  comp cat --header option
0.1.5 [Oct 10, 2021]
  fixes for hot pixel correction
0.1.6 [Oct 13, 2021]
  fixes for large temperature values promoted to doubles
0.1.7 [Nov 1, 2021]
  iquv image panels
  normalizing by NUMSUM during averaging
0.1.8 [Nov 2, 2021]
  end-of-day check for data/machine log
0.1.9 [Nov 5, 2021]
  fix for crash when T_C{0,1}{ARR,PCB} are not present
  normalize by NUMSUM by extension
0.1.10 [Nov 5, 2021]
  fix typo
0.1.11 [Nov 5, 2021]
  handle undefined temperatures in GBU checks
0.1.12 [Nov 5, 2021]
  remove normalization by NUMSUM when creating darks and flats
0.2.0 [Nov 9, 2021]
  fix bugs with calculating demodulation matrix
  fix continuum subtraction step for wave regions that don't subtract continuum
  adjust display parameters
0.2.1 [Nov 10, 2021]
  typo
0.2.2 [Nov 11, 2021]
  handle missing OCCLTR-{X,Y} values
0.2.3 [Dec 3, 2021]
  send emails from ucomp-pipeline@ucar.edu
  epoch for bad level 0 FITS on 20211202
0.2.4 [Dec 8, 2021]
  handle no raw directory
0.2.5 [Dec 9, 2021]
  new two-part method to find occulter
  V crosstalk metric
  adding/removing FITS keywords from level 0 to level 1
0.2.6 [Dec 15, 2021]
  fixed logic of when to mark date as processed
0.2.7 [Dec 22, 2021]
  basic metadata for ucomp_sci database table
  consistency in database table for wave_region
0.2.8 [Dec 25, 2021]
  handle odd science files with no center wavelength
0.2.9 [Jan 12, 2022]
  fix sign error in Q
  new all wavelengths, all polarization states plot for each science file
0.2.10 [Jan 21, 2022]
  experimental NRGF product
  compress level 0 .tgz files
0.2.11 [Jan 27, 2022]
  creates level 0 tarball, not .tgz, for archive
  new high gain hot pixel data
  average flats over polarization state
  save only averaged darks/flats in files
0.2.12 [Feb 3, 2022]
  config option to not interpolate darks
  fix for V crosstalk metric calculation
  fix for intensity GIF colors
  new demodulation matrix
0.2.13 [Feb 8, 2022]
  fix for verify sub-command
  fixes for weekly verification
  changing order of hot pixel correction
0.2.14 [Feb 14, 2022]
  add more geometry FITS keywords like [XY]OFFSET[01], POST_ANG
  prepping for realtime processing launch
0.2.15 [Feb 22, 2022]
  handle display of all wavelengths in files with many wavelengths
  fixes for realtime processing launch
  fix for BUNIT value, actually 1.0E-6 B/Bsun units
  V crosstalk plot by wave region
  log memory usage
  initial implementation of verification
0.2.16 [Feb 22, 2022]
  fix for crashing in memory plot creation routine
0.2.17 [Feb 22, 2022]
  fix for crashing in SGS plot creation routine
0.2.18 [Feb 22, 2022]
  fix for crashing in V crosstalk plot creation routine
0.2.19 [Feb 24, 2022]
  cyan-pink color table for polarization image display
  email notification handles files that don't pass quality
  fix GBU conditions listed in notification email
  full implementation of verification
0.2.20 [Feb 25, 2022]
  fix bugs in quality check
0.2.21 [Mar 1, 2022]
  intensity and IQUV movies
  quality logs
  better listing of quality/GBU issues in notification email
  fix verification bug examining scripts/ directory
0.2.22 [Mar 1, 2022]
  handle days with no raw files in verification
0.2.23 [Mar 2, 2022]
  make mp4 creation optional
0.2.24 [Mar 7, 2022]
  add IMAGESCL and MED_BACK FITS keywords
  updated display min/max values
  adding more information to ucomp_sci table and creating rolling synoptic maps
0.2.25 [Mar 8, 2022]
  add library dependency
0.2.26 [Mar 8, 2022]
  add library dependencies
0.2.27 [Mar 8, 2022]
  add ssw dependencies
0.2.28 [Mar 10, 2022]
  handle selecting files to put into ucomp_sci if there are no OK files
  plot centering information
0.2.29 [Mar 11, 2022]
  use processed flag for a file to determine if OK to use
0.2.30 [Mar 11, 2022]
  typo in processed flag
0.2.31 [Mar 11, 2022]
  linear polarization synoptic maps
  synoptic maps at 1.08 Rsun
0.2.32 [Mar 12, 2022]
  typo in synoptic map database field name
0.2.33 [Mar 14, 2022]
  radial azimuth and doppler velocity synoptic maps
  plot centering information by wave region
0.2.34 [Mar 21, 2022]
  improved performance for distortion correction
  make sure files to include in movies were fully processed
0.2.35 [Apr 5, 2022]
  fix for post angle reporting
  fix SGS plot colors/formatting
  using custom FITS writer to control keyword comments better
  allow flats in the future to be used
0.2.36 [Apr 11, 2022]
  slightly more general method for doppler calculation
0.2.37 [Apr 11, 2022]
  fix for database adding when no V crosstalk or doppler velocity
0.2.38 [Apr 11, 2022]
  add ability to inherit options in another config file
0.2.39 [May 18, 2022]
  add wind speed/direction to ucomp_file database table
  check for extra files, allow up to verification/max_missing missing files in
    verification, if they are not on the collection server
  flat interpolation option (default ON)
  creating partial level 2 dynamics files
  level 1 header updates: promoting common keywords to primary header
0.2.40 [May 27, 2022]
  write intensity only FITS files
  create dynamics and polarizations FITS and PNG files
0.2.41 [May 29, 2022]
  fix for creating dynamics/polarization files from less than 3 wavelengths
  handle masking files when post angle was not found
0.2.42 [May 30, 2022]
  fix for images where the post angle is not found
0.2.43 [Jun 3, 2022]
  better display of level 2 products
0.2.44 [Jun 14, 2022]
  handle no center wavelengths in a level 1 file
  put NULL for out-of-range V crosstalk metric values in the database
0.2.45 [Jun 16, 2022]
  handle raw files with no extensions
0.2.46 [Jul 7, 2022]
  allow quality to be turned off
  check cal quality: flats must have occulter out and diffuser in
  create enhanced intensity GIFs
  colorbars on all GIFs and PNGs except the all wavelength IQUV PNG
0.2.47 [Jul 9, 2022]
  handle missing SGS FITS keywords
0.2.48 [Jul 10, 2022]
  handle quality check for before 20210726
  handle missing T_ and TU_ FITS keywords
0.2.49 [Jul 11, 2022]
  fix for handling occulter ID of NONE
  handle file for ucomp_sci database table which does not have center wavelength
0.2.50
