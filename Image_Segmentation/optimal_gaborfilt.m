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

    % wavelength computation
    % retrieve necessary parameters for gabor filters
    % retrieve the wavelengths of the gabor filters
    [common_freq,max_freq,min_freq]=img_spatio_freq(image); % retreive the spatial frequency of the image
    common_wavelength=freq_wave_converter(common_freq); % convert the most common frequency to wavelength
    max_freq_wavelength=freq_wave_converter(max_freq); % convert the maximum frequency to wavelength
    min_freq_wavelength=freq_wave_converter(min_freq); % convert the minimum frequency to wavelength
    common_wavelength=sqrt(common_wavelength(1)^2 + ...
                           common_wavelength(2)^2);
    max_freq_wavelength=sqrt(max_freq_wavelength(1)^2 + ...
                             max_freq_wavelength(2)^2);
    min_freq_wavelength=sqrt(min_freq_wavelength(1)^2 + ...
                             min_freq_wavelength(2)^2);
    % computing the optimal wavelengthes for gabor filters
    % distribute the wave factor between the range of common and maximum
    % wavelength and common and minimum wavelength
    dist_commax=min_freq_wavelength-common_wavelength;
    dist_commin=common_wavelength-max_freq_wavelength;
    fact_commax=dist_commin/(dist_commin+dist_commax)*factor_wav;
    fact_commax=round(fact_commax);
    fact_commin=factor_wav-fact_commax;
    % make up the wave grids 
    % note that the gabbor filter function requires the wavelengthes to be
    % always larger or equal to 2
    grid_commax=max([2,max_freq_wavelength],[],'all'):(dist_commax)/fact_commax:max([2,common_wavelength],[],'all');
    grid_commin=max([2,common_wavelength],[],'all'):(dist_commin)/fact_commin:max([2,min_freq_wavelength],[],'all');
    grid_wavelengths=[grid_commax, grid_commin];

    % angle computation
    % divide the angle from 0 to 180 into several grids
    angle_add=round(180/(factor_angle));
    grid_angles=0*angle_add:angle_add:(factor_angle-1)*angle_add;

    % conduct gabor filtering
    if size(image,3)~= 1
        gray_img=rgb2gray(image);
    else
        gray_img=image;
    end
    % create gabor filters
    g = gabor(grid_wavelengths,grid_angles);
    [mag_gabor,phase_gabor]=imgaborfilt(gray_img,g);
    montage(mag_gabor,"size",[4 6])



end