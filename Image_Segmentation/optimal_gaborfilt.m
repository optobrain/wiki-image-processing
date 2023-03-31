% Created Date: March 9th, 2023
% Belong to: Leelab.ai
% Creator: Kuan-Min Lee
% Function Instruction:
% This function is created to compute a conversion for frequency to
% wavelength for usage for gabor filter function for MATLAB
% Function Arguments:
% freq: computed frequency from img_spatio_freq.m function
function [mag_gabor,phase_gabor]=optimal_gaborfilt(image,factor_wav,factor_angle)
    % check out if the input is empty
    % insert input parser for organizing the required and optional input
    p=inputParser;
    checkarray = @(x) ~isempty(x);
    checkinteger = @(x) isfinite(x) && x == floor(x);
    addRequired(p,"image",checkarray);
    addRequired(p,"factor_wav",checkinteger);
    addRequired(p,"factor_angle",checkinteger);
    parse(p,image,factor_wav,factor_angle);
    image=p.Results.image;
    factor_wav=p.Results.factor_wav;
    factor_angle=p.Results.factor_angle;

    % retrieve necessary parameters for gabor filters
    % retrieve the wavelengths of the gabor filters
    [common_freq,max_freq,min_freq]=img_spatio_freq(image); % retreive the spatial frequency of the image
    common_wavelength=freq_wave_converter(common_freq); % convert the most common frequency to wavelength
    max_wavelength=freq_wave_converter(max_freq); % convert the maximum frequency to wavelength
    min_wavelength=freq_wave_converter(min_freq); % convert the minimum frequency to wavelength

    % computing the optimal wavelength for gabor filters
 


end