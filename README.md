# HFO Automated Detector in iEEG

This an implementation of the method presented in ["Fedele, T., Burnos, S., Boran, E., Krayenbühl, N., Hilfiker, P., Grunwald, T. and Sarnthein, J., 2017. 
Resection of high frequency oscillations predicts seizure outcome in the individual patient. Scientific Reports, 7(1)."](https://doi.org/10.1038/s41598-017-13064-1). 
This paper is licensed under a [Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/) and is freely available.
This method is used to identify segments of iEEG with Ripples (80-250Hz) and Fast Ripples (250-500Hz) activities and their co-occurrence and use them to predict seizure outcome.

This implementation was our project for Cognitive Neuroscience Course. The original implementation by authors is also available on github
([https://github.com/HFO-detect/HFO-detect-matlab](https://github.com/HFO-detect/HFO-detect-matlab)).

# Using Instructions

In the function FindThreshold.m, we used another function written by Aditya Sundar (see [Aditya Sundar (2020). Time frequency distribution of a signal using S-transform (stockwell transform), 
MATLAB Central File Exchange. Retrieved May 18, 2020.](https://www.mathworks.com/matlabcentral/fileexchange/51808-time-frequency-distribution-of-a-signal-using-s-transform-stockwell-transform) 
to calculate TF distribution of signal using Stockwell Transform. Please download and add it to your matlab paths before running the code.
Then, simply run the Project.m to perform the algorithm on SampleData (which you can access in [http://dx.doi.org/10.6080/K06Q1VD5](http://dx.doi.org/10.6080/K06Q1VD5)).
the result will be stored in variables RippleSegments, FastRippleSegments and FRandRSegments. You can set some parameters manually
in the source code, such as MinOscillations, and parameters used to estimate the threshold.


# Authors
	
	Ali Mohammadi
	Morteza Fattahi
