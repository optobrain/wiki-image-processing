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
    spatio_freq=img_spatio_freq(image); % retreive the spatial frequency of the image
    wavelength=freq_wave_converter(spatio_freq); % convert the spatial frequency to wavelength
    % retrieve the tested wavelength
    lower_bound=max(2,wavelength-floor(factor_wav/2)*wavelength/(factor_wav));
    % if the lower bound for the wavelength is 2
    % setup corresponding upper bound and grid size
    if lower_bound==2
        grid_size=(wavelength-lower_bound)/floor(factor_wav/2);
        upper_bound=wavelength+floor(factor_wav/2)*grid_size;
    % if the lower bound for the wavelength is larger than 2
    % setup the corrsponding upper boundd and grid size
    else
        grid_size=wavelength/(factor_wav);
        upper_bound=wavelength+floor(factor_wav/2)*grid_size;
    end
    % get the tested wavelengths portion    
    test_wavelengths=lower_bound:grid_size:upper_bound;
    % retrieve the angles of the gabor filters
    angle_add=round(180/(factor_angle));
    test_angles=0*angle_add:angle_add:(factor_angle-1)*angle_add;

    % conduct gabor filtering
    if size(image,3)~= 1
        gray_img=rgb2gray(image);
    else
        gray_img=image;
    end
    % create gabor filters
    g = gabor(test_wavelengths,test_angles);
    [mag_gabor,phase_gabor]=imgaborfilt(gray_img,g);

end