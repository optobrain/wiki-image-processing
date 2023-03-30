% Created Date: March 9th, 2023
% Belong to: Leelab.ai
% Creator: Kuan-Min Lee
% Function Instruction:
% This function is created to compute a conversion for frequency to
% wavelength for usage for gabor filter function for MATLAB
% Function Arguments:
% freq: computed frequency from img_spatio_freq.m function
function wavelength=freq_wave_converter(freq)
    % check out if the input is empty
    % insert input parser for organizing the required and optional input
    p=inputParser;
    checkinput = @(x) ~isempty(freq);
    addRequired(p,"freq",checkinput);
    parse(p,freq);
    freq=p.Results.freq;

    % conduct frequency to wavelength conversion
    wavelength=1./freq;
    
end