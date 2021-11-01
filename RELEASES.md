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
