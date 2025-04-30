# Release notes

#### 0.1.0 [Sep 23, 2021]

- create inventory files
- create master dark file
- create master flat file
- average data in science files with the same wavelength, gain mode, etc.
- apply dark/flat correction
- demodulation
- apply distortion
- continuum subtraction
- combine cameras

#### 0.1.1 [Sep 28, 2021]

- promote issues in observing plan that prevent calibration to errors from warnings
- C implementation of demodulation
- handle epochs with no OCCLTR-{X,Y} values in FITS headers

#### 0.1.2 [Oct 5, 2021]

- option to write only center wavelength intensity or all extensions
- use non-matching exposure time flats
- fix hot pixels

#### 0.1.3 [Oct 5, 2021]

- fixes for hot pixel correction

#### 0.1.4 [Oct 8, 2021]

- ucomp cat --header option

#### 0.1.5 [Oct 10, 2021]

- fixes for hot pixel correction

#### 0.1.6 [Oct 13, 2021]

-  fixes for large temperature values promoted to doubles

#### 0.1.7 [Nov 1, 2021]

- iquv image panels
- normalizing by NUMSUM during averaging

#### 0.1.8 [Nov 2, 2021]

- end-of-day check for data/machine log

#### 0.1.9 [Nov 5, 2021]

- fix for crash when T_C{0,1}{ARR,PCB} are not present
- normalize by NUMSUM by extension

#### 0.1.10 [Nov 5, 2021]

- fix typo

#### 0.1.11 [Nov 5, 2021]

- handle undefined temperatures in GBU checks

#### 0.1.12 [Nov 5, 2021]

- remove normalization by NUMSUM when creating darks and flats

#### 0.2.0 [Nov 9, 2021]

- fix bugs with calculating demodulation matrix
- fix continuum subtraction step for wave regions that don't subtract continuum
- adjust display parameters

#### 0.2.1 [Nov 10, 2021]

- typo

#### 0.2.2 [Nov 11, 2021]

- handle missing OCCLTR-{X,Y} values

#### 0.2.3 [Dec 3, 2021]

- send emails from ucomp-pipeline@ucar.edu
- epoch for bad level 0 FITS on 20211202

#### 0.2.4 [Dec 8, 2021]

- handle no raw directory

#### 0.2.5 [Dec 9, 2021]

- new two-part method to find occulter
- V crosstalk metric
- adding/removing FITS keywords from level 0 to level 1

#### 0.2.6 [Dec 15, 2021]

- fixed logic of when to mark date as processed

#### 0.2.7 [Dec 22, 2021]

- basic metadata for ucomp_sci database table
- consistency in database table for wave_region

#### 0.2.8 [Dec 25, 2021]

- handle odd science files with no center wavelength

#### 0.2.9 [Jan 12, 2022]

- fix sign error in Q
- new all wavelengths, all polarization states plot for each science file

#### 0.2.10 [Jan 21, 2022]

- experimental NRGF product
- compress level 0 .tgz files

#### 0.2.11 [Jan 27, 2022]

- creates level 0 tarball, not .tgz, for archive
- new high gain hot pixel data
- average flats over polarization state
- save only averaged darks/flats in files

#### 0.2.12 [Feb 3, 2022]

- config option to not interpolate darks
- fix for V crosstalk metric calculation
- fix for intensity GIF colors
- new demodulation matrix

#### 0.2.13 [Feb 8, 2022]

- fix for verify sub-command
- fixes for weekly verification
- changing order of hot pixel correction

#### 0.2.14 [Feb 14, 2022]

- add more geometry FITS keywords like [XY]OFFSET[01], POST_ANG
- prepping for realtime processing launch

#### 0.2.15 [Feb 22, 2022]

- handle display of all wavelengths in files with many wavelengths
- fixes for realtime processing launch
- fix for BUNIT value, actually 1.0E-6 B/Bsun units
- V crosstalk plot by wave region
- log memory usage
- initial implementation of verification

#### 0.2.16 [Feb 22, 2022]

- fix for crashing in memory plot creation routine

#### 0.2.17 [Feb 22, 2022]

- fix for crashing in SGS plot creation routine

#### 0.2.18 [Feb 22, 2022]

- fix for crashing in V crosstalk plot creation routine

#### 0.2.19 [Feb 24, 2022]

- cyan-pink color table for polarization image display
- email notification handles files that don't pass quality
- fix GBU conditions listed in notification email
- full implementation of verification

#### 0.2.20 [Feb 25, 2022]

- fix bugs in quality check

#### 0.2.21 [Mar 1, 2022]

- intensity and IQUV movies
- quality logs
- better listing of quality/GBU issues in notification email
- fix verification bug examining scripts/ directory

#### 0.2.22 [Mar 1, 2022]

- handle days with no raw files in verification

#### 0.2.23 [Mar 2, 2022]

- make mp4 creation optional

#### 0.2.24 [Mar 7, 2022]

- add IMAGESCL and MED_BACK FITS keywords
- updated display min/max values
- adding more information to ucomp_sci table and creating rolling synoptic maps

#### 0.2.25 [Mar 8, 2022]

- add library dependency

#### 0.2.26 [Mar 8, 2022]

- add library dependencies

#### 0.2.27 [Mar 8, 2022]

- add ssw dependencies

#### 0.2.28 [Mar 10, 2022]

- handle selecting files to put into ucomp_sci if there are no OK files
- plot centering information

#### 0.2.29 [Mar 11, 2022]

- use processed flag for a file to determine if OK to use

#### 0.2.30 [Mar 11, 2022]

- typo in processed flag

#### 0.2.31 [Mar 11, 2022]

- linear polarization synoptic maps
- synoptic maps at 1.08 Rsun

#### 0.2.32 [Mar 12, 2022]

- typo in synoptic map database field name

#### 0.2.33 [Mar 14, 2022]

- radial azimuth and doppler velocity synoptic maps
- plot centering information by wave region

#### 0.2.34 [Mar 21, 2022]

- improved performance for distortion correction
- make sure files to include in movies were fully processed

#### 0.2.35 [Apr 5, 2022]

- fix for post angle reporting
- fix SGS plot colors/formatting
- using custom FITS writer to control keyword comments better
- allow flats in the future to be used

#### 0.2.36 [Apr 11, 2022]

- slightly more general method for doppler calculation

#### 0.2.37 [Apr 11, 2022]

- fix for database adding when no V crosstalk or doppler velocity

#### 0.2.38 [Apr 11, 2022]

- add ability to inherit options in another config file

#### 0.2.39 [May 18, 2022]

- add wind speed/direction to ucomp_file database table
- check for extra files, allow up to verification/max_missing missing files in
  verification, if they are not on the collection server
- flat interpolation option (default ON)
- creating partial level 2 dynamics files
- level 1 header updates: promoting common keywords to primary header

#### 0.2.40 [May 27, 2022]

- write intensity only FITS files
- create dynamics and polarizations FITS and PNG files

#### 0.2.41 [May 29, 2022]

- fix for creating dynamics/polarization files from less than 3 wavelengths
- handle masking files when post angle was not found

#### 0.2.42 [May 30, 2022]

- fix for images where the post angle is not found

#### 0.2.43 [Jun 3, 2022]

- better display of level 2 products

#### 0.2.44 [Jun 14, 2022]

- handle no center wavelengths in a level 1 file
- put NULL for out-of-range V crosstalk metric values in the database

#### 0.2.45 [Jun 16, 2022]

- handle raw files with no extensions

#### 0.2.46 [Jul 7, 2022]

- allow quality to be turned off
- check cal quality: flats must have occulter out and diffuser in
- create enhanced intensity GIFs
- colorbars on all GIFs and PNGs except the all wavelength IQUV PNG

#### 0.2.47 [Jul 9, 2022]

- handle missing SGS FITS keywords

#### 0.2.48 [Jul 10, 2022]

- handle quality check for before 20210726
- handle missing `T_` and `TU_` FITS keywords

#### 0.2.49 [Jul 11, 2022]

- fix for handling occulter ID of NONE
- handle file for ucomp_sci database table which does not have center wavelength

#### 0.2.50 [Jul 13, 2022]

- handle NaN values for total I, Q, U in ucomp_sci database table

#### 0.2.51 [Jul 21, 2022]

- fix bugs in dark count/temperature engineering plots
- verification fixes

#### 0.2.52 [Jul 27, 2022]

- new hot pixel file for high gain mode
- level 2 individual images
- level 2 movies

#### 0.2.53 [Aug 2, 2022]

- flat engineering plots

#### 0.2.54 [Aug 2, 2022]

- adding missing file

#### 0.2.55 [Aug 3, 2022]

- fix bug if no flats for a given wavelength/onband combination

#### 0.2.56 [Aug 4, 2022]

- add median line center and continuum values to database
- make plots of dark and flat medians over time from the database

#### 0.2.57 [Aug 8, 2022]

- fix for graphics issue with dark/flat median plots over time from database
- storing median background of each file in database

#### 0.2.58 [Aug 9, 2022]

- fix minor issues with dark/flat plots
- make plot of median backgrounds over mission
- use wave region display options to display synoptic maps

#### 0.2.59 [Aug 12, 2022]

- minor changes to title of rolling dark plot
- change to epoch based wave region options

#### 0.2.60 [Aug 15, 2022]

- fix for cal file quality check
- add check for consistent data types for cal file extensions
- combine MFLTEXT{1,2} keyword values for subtracted continuum extensions

#### 0.2.61 [Aug 16, 2022]

- better messages for verification log

#### 0.2.62 [Aug 23, 2022]

- allow flat/cal combined datatype files
- quality check on median dark value
- add occulter and quality fields to ucomp_cal database table
- adjust ranges in dark plots
- all quality check for any extension being identically zero
- add in/out quality check for cal files
- making mp4s in /tmp directory
- fix for missing ssh key in checking for missing files in verification
- potential fix for low background values (sum over pol state instead of mean)
- new demodulation coefficients

#### 0.2.63 [Aug 24, 2022]

- fix for bug in previous fix for low background values

#### 0.2.64 [Aug 24, 2022]

- change valid dark value range by epoch

#### 0.2.65 [Aug 31, 2022]

- create averages of level 1 files
- adjust background plot ranges for some wave regions
- updated ranges for rolling dark and flat plots
- archive and distribute level 1 and 2 data
- use background I instead of sum of pol states for backgrounds
- fix error in display of synoptic maps

#### 0.2.66 [Sep 1, 2022]

- fix for log message when not archiving level 0 data

#### 0.2.67 [Sep 1, 2022]

- fix for typo in module name in ucomp script

#### 0.2.68 [Sep 12, 2022]

- fix for creating quick invert of non-existent average file

#### 0.2.69 [Sep 22, 2022]

- rolling flat plot annotation improvements
- check for level 1 files before using them in creating averages
- change enhanced intensity parameters
- additions to rolling dark plots

#### 0.2.70 [Sep 26, 2022]

- display adjustments for intensity

#### 0.2.71 [Sep 27, 2022]

- fixes for averaging

#### 0.2.72 [Sep 30, 2022]

- fix for no OK files to average
  rolling plot of dark corrected flats

#### 0.2.73 [Nov 3, 2022]

- added O1ID entry to ucomp_eng database table
- added new lines: 670, 761, 802, 991

#### 0.2.74 [Nov 14, 2022]

- a fix for the new wave regions added this week

#### 0.2.75 [Nov 16, 2022]

- fix reversed XOFFSET{0,1} FITS keyword
- add DEMOD FITS keyword
- new demodulation coefficient file with temporary 670, 761, 802, 991 values

#### 0.2.76 [Nov 18, 2022]

- change DEMOD to DEMOD_C including a better date format in comment

#### 0.2.77 [Nov 20, 2022]

- fix for handling rolling background plot with only a single value
- skipping trying to make movies with only a single frame

#### 0.2.78 [Nov 23, 2022]

- new display ranges for new lines

#### 0.2.79 [Nov 23, 2022]

- fix center wavelength for 991 wave region

#### 0.2.80 [Nov 25, 2022]

- fix center wavelength for more new wave regions: 670, 802, 991
- fix for typo in machine log validation that caused crashes

#### 0.2.81 [Nov 28, 2022]

- change center wavelength by epoch for new lines

#### 0.2.82 [Nov 28, 2022]

- fix typo

#### 0.2.83 [Mar 22, 2023]

- add backgrounds to level 1 FITS files
- fix MED_BACK FITS keyword calculation
- subtract rest wavelength in velocity calculation
- fix for RAWEXTS, FLTFILE{1,2}, and MFLTEXT{1,2} keywords
- improved center finding
    - ignore data under post for radial derivative
    - better initial guesses for center and radius
    - find mean over polarization state of background used for center finding
- center and rotate in a single interpolation
- add "vectorized" option for demodulation
- add CONFIG_DIR CMake variable
- allow config files to inherit from another config file
- fix for finding dark when not interpolating (find nearest instead of previous)
- move the dark correction to before the camera correction
- change extension names from "sci [WWWW.WW nm]" to "Stokes IQUV [WWWW.WW nm]"
- add scheme to convert cookbook names to better user names for average files
- updating radial azimuth color table to match CoMP
- report eccentricity/angle in FITS header, database, and daily plot

#### 0.2.84 [Mar 23, 2023]

- handle missing files for composite images

#### 0.2.85 [Mar 23, 2023]

- handle missing files for composite images

#### 0.2.86 [Apr 11, 2023]

- using CIRCFIT for occulter center finding
- fix for finding configuration file for verification script
- fix for finding post
- horizontal debanding

#### 0.2.87 [May 23, 2023]

- change display min/max for radial azimuth to +/- 50.0
- improved GBU
- ability to remove bad frames
- creating quick invert FITS and PNGs
- adding backgrounds to average files
- fixed post finding
- adding mean/median and quick invert files to ucomp_file database table
- can specify dates in options/dates in config file for eod, rt, cal, clearday,
  reprocess, regression, script, and archive sub-commands
- fixed temperature composite images
- produce image scale plot for evaluating changes in plate scale
- updating FITS keywords

#### 0.3.0 [May 25, 2023]

- change quality conditions checked in early mission
- option to not perform noise masking in level 2 products

#### 0.3.1 [Jun 6, 2023]

- handle extra files in the raw directory with ".fts" in the filename

#### 0.3.2 [Jun 7, 2023]

- report correct quality in ucomp_raw database table

#### 0.3.3 [Jun 12, 2023]

- FITS header changes

#### 0.4.0 [Jul 20, 2023]

- FITS header changes
- change filenames to full words
- updated image annotations/display parameters
- remove threshold masking in enhanced intensity
- polarization/dynamics and quicklook distribution
- mask 706 nm level 1 quicklook images
- scale radial azimuth from -90 to 90 degrees with band on Van Vleck angle
- create individual quicklook images from quick invert extensions
- change Q, U, and V color table to linear black/white
- option to do centering before the gain correction
- track saturated pixels and pixels in the non-linear region of the camera
- update engineering plot filenames to include "mission" if over entire mission
- option to create engineering difference images when combining cameras

#### 0.4.1 [Jul 22, 2023]

- publish individual mean/median and quick invert FITS files along with tarballs
- publish quick invert line width and velocity individual quicklook images
- fix bugs in temperature map creation and publishing
- change quality condition for non-dark corrected pixels in non-linear regime
  to 3200 DN (normalized by NUMSUM)

#### 0.4.2 [Jul 24, 2023]

- fix crash with saturated pixel check when only a single extension for a given
  camera
- scale velocity images for all wave regions to -5 to 5
- publish azimuth PNGs/mp4s from polarization files
- update num_ucomp field in mlso_numfiles database
- update display parameters for temperature maps

#### 0.4.3 [Jul 25, 2023]

- fix azimuth image from polarization file
- put Q, U, L not Q/I, U/I, and L/I in quick invert FITS file

#### 0.4.4 [Jul 30, 2023]

- pipeline control command infrastructure
- ucomp versions reports days in progress
- fix L / I annotation for quick invert quicklook
- fix for crash in rolling flat plot with exactly one day

#### 0.4.5 [Jul 30, 2023]

- epoch file additions

#### 0.4.6 [Aug 2, 2023]

- check that wavelengths in science file match the wave region of the file
- fix in cal quality check for days where many flats don't pass quality

#### 0.4.7 [Aug 4, 2023]

- fix for intensity FITS file extension names
- add intensity FITS files to ucomp_file database table
- categorizing program names into synoptic, waves, and do-not-use
- better program name construction
- fix bugs in filtering bad level 1 files out of level 2
- fixes for level 1 publishing only good files

#### 0.5.0 [Aug 18, 2023]

- put number of *good* level 1 FITS files in num_ucomp field of mlso_numfiles
- put only written level 1 FITS files into ucomp_file database table
- put only good level 1 FITS files into ucomp_sci database table
- make daily engineering plots more consistent
- create new mission length engineering plots
- implement median difference GBU check
- update all level 1 and 2 image annotations
- change masking thresholds
- change line width display min/max
- updated method to compute enhanced peak intensity

#### 1.0.0 [Nov 22, 2023]

- added `--tail` option to log sub-command
- fix for mysterious hang when process finished
- new level 2 file format and filenames
- change to FWHM for line width
- better averaging criteria (no gap larger than 30 min)
- new tarball/zip file organization for distribution to website
- split ucomp_sci into dynamics and polarization tables
- rest wavelength model for 1074 nm data
- complete set of WCS FITS keywords specifying location
- user documentation

#### 1.0.1 [Nov 29, 2023]

- fixed bug in "image" rest wavelength calculation method
- use "image" rest wavelength calculation method for 1074 nm files
- fix display for 789 nm enhanced intensity quicklook images
- over mask occulter for pixels used in rest wavelength calculation
- fix script updating database plots that removed UCoMP entry in mlso_numfiles
- fix display of 706 nm IQUV (all wavelengths) quicklook images

#### 1.0.2 [Apr 10, 2024]

- hot pixel list for new camera
- improved hot pixel list and more generic application
- distortion for new camera
- move distortion files to directory specified by config file
- improved ordering of level 1 FITS keywords
- config file options to turn off distortion/hot pixel corrections
- handle SGSDIMV value of 0.0

#### 1.0.3 [Apr 11, 2024]

- display 3 decimal points for wavelengths in IQUV all images

#### 1.0.4 [Apr 11, 2024]

- fix for hot pixel correction

#### 1.0.5 [Apr 15, 2024]

- more epoch updates for the eclipse data
- new program synonym names

#### 1.0.6 [May 6, 2024]

- more epoch updates for the eclipse data
- thumbnails for the website

#### 1.0.7 [May 6, 2024]

- update display min for 637 nm enhanced intensity

#### 1.0.8 [May 7, 2024]

- change OBS_PLAN to a synoptic program for a 20240330 1074 nm file

#### 1.0.9 [May 7, 2024]

- fix for creating temperature map on 20240330

#### 1.0.10 [July 22, 2024]

- added angle grid on quicklooks
- adding DISTORTF and HOTPIXF FITS keywords
- improved post finding
- improved quality check for too many missing frames
- option to perform Gaussian fit to calculate peak intensity, LOS velocity, and
  line width
- use reference wavelengths for 3-point analytic Gaussian calculation
- added quality thresholds for flats
- updated distortion and hot pixels
- changes for new wave regions

#### 1.0.11 [July 22, 2024]

- fix for crash in creating mission image scale plot

#### 1.0.12 [July 22, 2024]

- fix for crash in creating mission image scale plot

#### 1.0.13 [July 23, 2024]

- update documentation
- fix for days with unprocessed, ambiguous wave region level 0 files
- log messages about files that fail inventory

#### 1.0.14 [July 24, 2024]

- check if wave region is published for number of good files for a day

#### 1.0.15 [July 24, 2024]

- fix for unknown wave region of file

#### 1.0.16 [Aug 27, 2024]

- fix for weekly verification

#### 1.0.17 [Mar 24, 2025]

- fix for mlso_numfiles entry

#### 1.0.18 [Apr 30, 2025]

- automatically find files for computing density
- updated temperature thresholds for quality check
- updated logic for identical temperature check
- more efficient average calculations
- faster mission image scale plot
- ability to turn off individual GBU checks for time period
- publish level 3 data products
- fix bug in flat roughness calculation
- handle bad frames better
- specify minimum number of files need to create average for GBU test
