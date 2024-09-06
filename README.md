# Investigating the effects of calibration errors on the spatial resolution of OPM-MEG beamformer imaging
This repository contains codes to run the analyses presented in: Investigating the effects of calibration errors on the spatial resolution of OPM-MEG beamformer imaging. The use of optically pumped magnetometers (OPMs) has provided a feasible, moveable and wearable alternative to superconducting detectors for magnetoencephalography (MEG) measurement. Recently the beamformer imaging technique has greatly improved spatial accuracy of MEG and been widely used in the field of source reconstruction of neuroimaging. This manuscript explores the spatial resolution of the source reconstruction by beamformer imaging technique. The spatial accuracy of a beamformer reconstruction depends on accurate estimation of data covariance matrix and lead field. In practical measurement, many errors of sensor calibration including gain error, crosstalk and angular error of sensitive axis of OPMs due to for example the low frequency magnetic field drift will distort the measured data as well as forward model and thus reduce the spatial resolution. We first provide the theory of optically pumped magnetometer’s calibration errors based on Bloch equations. The calibration errors are then quantified using self-developed OPM array. And an analytical relationship between Frobenius norm of the covariance matrix error and gain error, crosstalk was derived. The relationship between point-spread function (PSF) and the forward model error caused by angular error of sensitive axis was analyzed. Finally, the effects of calibration errors on the spatial resolution of OPM-MEG were investigated using simulations of two dipoles with orthogonal signals at the source level based on realistic head models. We find the presence of calibration errors will decrease the spatial resolution of beamformer reconstruction. And this decrease will become more severe as the signal-to-noise ratio increases.
We believe that this work could be useful for the field of electrophysiology.

* Please check that the path to data is correct prior to running the codes

When starting a new data analysis project, you can use this repository as a template to get you started.

## Explanation of all the files in this repository

| Filename                | Explanation   |
|-------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| sim_opm_template             | construction of OPM array where many parameters such as the axis number, distance between opm and scalp can be set 
| angualr_err      | considering the angular error of opm array to creat the new lead field                 
| crosstalk_err     | creat crosstalk error matrix for single matrix                                                                                                                                                                 |    
| README.md               | The README document you are currently reading.                                                                                                                                                       |
|gain_error      | considering the angular error of opm array to alter the simulated meg data            |
| simresolution_correlation | the main function to simulate the effect of different calibration errors on the spatial resolution of beamformer imaging.
| dodo.py                 | A version of the main script that is meant to be consumed by the build system "pydoit". Use either this script as main script or use `main.py`.                                                |
| figure_example1.py      | Script that produces the first figure in this analysis.                                                                                                                                              |                

