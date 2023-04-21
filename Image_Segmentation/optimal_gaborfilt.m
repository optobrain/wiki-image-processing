% Created Date: March 9th, 2023
% Belong to: Leelab.ai
% Creator: Kuan-Min Lee
% Function Instruction:
% This function is created to compute a optimal gabor filter banks based on the utilization of function:
% img_spatio_freq, freq_wave_converter, optimal_wav_gen, optimal_ang_gen,
% and gabor function (from MATLAB)
% Function Arguments:
% image: test image (data size:(width image, length image, channel image)), 
% factor_wav: the number of tested wavelengths (data size: one single integer)
% factor_angle: the number of tested angles (data size: one single integer)
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

    % wavelength computation
    % retrieve necessary parameters for gabor filters
    % retrieve the wavelengths of the gabor filters
    [common_freq,common_ang]=img_spatio_freq(image); % retreive the spatial frequency of the image
    common_wavelength=freq_wave_converter(image,common_freq); % convert the most common frequency to wavelength
    % convert the maximum frequency to wavelength
    fs=1;
    nx=size(image,2);
    ny=size(image,1); 
    max_freq_x=(nx/2-1)*(fs/nx); % x direction
    max_freq_y=(ny/2-1)*(fs/ny); % y direction
    max_freq_wavelength_x=freq_wave_converter(image,max_freq_x); 
    max_freq_wavelength_y=freq_wave_converter(image,max_freq_y); 
    min_freq_x=(1)*(fs/nx); % x direction
    min_freq_y=(1)*(fs/ny); % y direction
    min_freq_wavelength_x=freq_wave_converter(image,min_freq_x); 
    min_freq_wavelength_y=freq_wave_converter(image,min_freq_y); 
    common_wavelength=sqrt(common_wavelength(1)^2 + ...
                           common_wavelength(2)^2);
    max_freq_wavelength=sqrt(max_freq_wavelength_x^2 + ...
                             max_freq_wavelength_y^2);
    min_freq_wavelength=sqrt(min_freq_wavelength_x^2 + ...
                             min_freq_wavelength_y^2);
    % compute optimal wavelengths
    optimal_waves=optimal_wav_gen(common_wavelength,max_freq_wavelength,min_freq_wavelength,factor_wav);

    % angle computation
    % divide the angle from 0 to 180 into several grids
    optimal_angs=optimal_ang_gen(common_ang,max_freq_x,max_freq_y, min_freq_x, min_freq_y,factor_angle);

    % conduct gabor filtering
    if size(image,3)~= 1
        gray_img=im2gray(im2single(image));
    else
        gray_img=image;
    end
    % create gabor filters
    g = gabor(optimal_waves,optimal_angs);
    [mag_gabor,phase_gabor]=imgaborfilt(gray_img,g);
    montage(mag_gabor,"size",[4 6])



end