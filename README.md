This repository contains code required to reproduce the analyses in Wainio-Theberge et al. (2020): Bridging the gap – Spontaneous fluctuations shape stimulus-evoked spectral power.
x
To use the functions in this repository, the repository must be added to the MATLAB path with all subfolders. For MEG data, Fieldtrip must also be installed and set up; for EEG data, both EEGLAB and Fieldtrip are required. To do the preprocessing, MNE-Python must also be installed, as well as the Human Connectome Project's megconnectome software. You will also need to install the AutoReject package (https://github.com/autoreject/autoreject).

## Preprocessing
The preprocessing functions for the CamCAN dataset are camcan_preproc.m and camcan_preproc_1Hz.m. For each one, the only inputs you need are the CamCAN subid (CCxxxxxx) and the file name ('some/directory/transdef_transrest_mf2pt2_task_raw.fif). The CC IDs of all subjects used in the study are provided in CCids.txt and CCids_IRASA.txt, so you can loop through those to do the preprocessing. 

EEG preprocessing did not use any in-house scripts, so you should be able to follow the methods in the paper to reproduce that. ASR was done with default settings, with the exception that no data epochs were removed (only interpolation done), and line noise was not cleaned since the original lowpass frequency was 50 Hz. ICA and MARA classification were also done with default settings. 

## Spontaneous-evoked correlation
The function NA_analysis.m will do the main analyses of spontaneous-evoked interaction using the pseudotrial and TTV methods. It operates on a settings structure; required fields of the settings structure are described in the help text of the function. Settings structures corresponding to the analyses in the paper have been included with this repository; you will have to modify the paths to the files to suit your particular system.

settings_camcan_1Hz_revision: settings structure for the 1Hz highpass CamCAN data. This is the settings structure for figures 2 and 3 in the main text. 

settings_camcan_1Hz_xxprestim: settings structure as above, but with different prestim lengths. Reproduces figures S4-S7. 

settings_camcan_nohp.mat: no highpass filter, reproduces figure S9

settings_camcan_noadj400.mat: prestim period moved back to -400 ms; reproduces figure S10.

settings_camcan_IRASAtf_osci/frac.mat: settings for the oscillatory-fractal decomposition, oscillatory and fractal components. Together these reproduce figures 6, S1, and S8.

settings_wolff2019.mat: settings for the EEG replication dataset; reproduces figures 7 and 8. 


To create the figures, find the appropriate figure type in NA_figures_script, load the appropriate settings, allmeas and results files, and run the code. To generate figure 5B (spontaneous-evoked correlation of fractal slope and intercept), use the script NAPLE_plot.m.

## Other scripts
Other figures in the text use other functions. 

Simulations (figures S2 and S3): 
The analyses and visualization for the simulation results are performed using NA_simulation_negative.m and NA_simulation_positive.m, respectively.

Randomly chosen remote pseudotrials (figures S8 and S9): 
To reproduce this analysis, use the settings structure settings_camcan_remotepseudo.mat, but use the function NA_tf_camcan_randpseudo.m instead of NA_tf_func.m to do time-frequency analysis. Calculate results and plot figures as normal.

Time-domain spontaneous-evoked correlation in different frequency bands (figure S14):
Use NA_erpfbands.m to generate the allmeas and results structures. The figure is the same template as figure 2 in the main text, so use NA_figures_script.m to generate this.

Phase-amplitude coupling (figure S15):
To reproduce this analysis, you will need the codes from Voytek et al. (2013), found here: http://darb.ketyov.com/professional/publications/erpac.zip. NA_get_erpac.m should be run first, and then NA_erpac_corr.m will do the analysis and produce the figure.

Behavioural analyses (figures S16 and S17):
To reproduce the mixed-effects models in figure S16, use NA_behaviour_func.m in conjunction with the camcan_1Hz_revision settings structure to do the analyses. Use NA_plot_behav.m to plot the figure.
To reproduce the comparison of the moral and control conditions in the EEG data (figure S17), first do the analyses separately on the moral and control conditions with their respective settings structures, then generate the statistics using NA_compare_outputs.m. The plot uses the same code as figure 5c in the main text (found in NA_figures_script.m). 

## Reuse

You may use these codes to do similar analyses of spontaneous-evoked interaction in other datasets by modifying the settings structures. If you do, please cite this paper: 

Wainio-Theberge, S., Wolff, A., & Northoff, G. (2020). Bridging the gap – Spontaneous fluctuations shape stimulus-evoked spectral power. bioRxiv. https://doi.org/10.1101/2020.06.23.166058 

This code makes use of the Sigstar library (https://github.com/raacampbell/sigstar) under the GNU Lesser GPL v3, as well as Fieldtrip (https://github.com/fieldtrip/fieldtrip) under GNU GPL v2, megconnectome (https://github.com/Washington-University/megconnectome), IRASA (https://purr.purdue.edu/publications/1987/1), and restingIAF (https://github.com/corcorana/restingIAF) under GNU GPL v3, and stdshade (https://www.mathworks.com/matlabcentral/fileexchange/29534-stdshade), export_fig (https://www.mathworks.com/matlabcentral/fileexchange/23629-export_fig), and panel (https://www.mathworks.com/matlabcentral/fileexchange/20003-panel) under the BSD 3-clause license.

This code is available under the GNU General Public License v3.
