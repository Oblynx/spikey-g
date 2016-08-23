clear; close all;
load codi;
x=bul_Averageptes02;
fs=250;

eegcwt(x(1:2,:), fs, 8, 'morl');
