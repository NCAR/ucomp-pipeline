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
0.1.2
  option to write only center wavelength intensity or all extensions
