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
0.2.21
