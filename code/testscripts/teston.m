clear; close all;
load('data/PTES_2/matfilesT1/ptes02 20160704 1141.T1.-0.mat');
x=bul_Averageptes02;
fs=250;

eegcwt(x([1 25],:), fs, 8, 'morl', 'image');
