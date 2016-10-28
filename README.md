# spikey-g: Characterization of bullying behaviour from EEG data

## Goal

This is a project that analyzes experimental EEG data in order to discover EEG patterns related to the perception of
bullying.

## Experiment

The data that are used come from an EEG experiment where 18 participants watch a video with explicit scenes of bullying
in a school environment. Through the feeling of empathy, it is conjectured that the videos will, to some extent, elicit
in the viewer similar emotional responses as if he was experiencing the bullying himself. Testing this conjecture, which
aligns with recent research in the concept of mirror neurons, is a primary research question.

The experiments actually conducted are 2:
  1. `eeg_experiment/matfilesT1`: the video is watched on a desktop monitor
  2. `eeg_experiment/matfilesT2`: the video is watched on a virtual reality headset
   
## Analysis

The same data are given to many teams to experiment with different analysis techniques. Our team uses _wavelet analysis_.
The analyses are all based on the concept of Event-related Potentials (ERPs), which are systematic time-domain eeg
responses elicited at a specific latency after the stimulus. They are in the form of a large sustained positive or negative
rise in the eeg amplitude in particular regions of the brain. The ERPs we examined are the "Early Posterior Negativity"
(EPN), N170, P300 and LPP.

#### Note on data

The eeg recordings were split into epochs and considered either "bullying" or "no bullying". The epochs from each class were
averaged along the time axis, so in the end for each subject there are the following data matrices:
  - bul: [256 channels]x[200 time samples] the average of the bullying epochs
  - nobul: [256 channels]x[200 time samples] the average of the no bullying epochs

### Analysis overview

The analysis follows these steps:
  1. Selection of the time window and the channels associated with a particular ERP from the entire eeg dataset.
  2. Wavelet transform of the selected signals.
  3. Detection of the most prominent peaks
  4. Feature extraction: for each peak, we extract:
    1. amplitude
    2. frequency
    3. width
  5. Compilation of a dataset from the features of all the selected channels from all the participants
  6. Training and cross-validation of an SVM classifier for the 2-class {bul,nobul} problem.

### Wavelet analysis

### SVM classification

