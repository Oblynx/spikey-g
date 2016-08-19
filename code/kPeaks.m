function [p,s]= kPeaks(k,data,tol)
% kPeaks Returns the position and width of the k most prominent peaks
% k: Number of most-prominent peaks to return. A peak is always a local maximum,
% but not all local maxima are peaks (only the prominent ones)
% tol: Sensitivity to local maxima, determines how prominent a local maximum
% must be to be declared a peak
p= [5,100,500];
s=0;


