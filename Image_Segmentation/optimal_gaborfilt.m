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
    [common_freq, common_wav,common_ang, pks_freq, pks_wav, pks_ang]=img_spatio_freq(image,factor_wav,factor_angle); % retreive the spatial frequency of the image    
    % conduct gabor filtering
    if size(image,3)~= 1
        gray_img=im2gray(im2single(image));
    else
        gray_img=image;
    end
    % remove na or inf values
    pks_wav=pks_wav(~(isnan(pks_wav)|isinf(pks_wav)));
    pks_ang=pks_ang(~(isnan(pks_ang)|isinf(pks_ang)));
    

    % create gabor filters
    g = gabor(pks_wav,pks_ang);
    [mag_gabor,phase_gabor]=imgaborfilt(gray_img,g);
%     montage(mag_gabor,"size",[4 6])



end