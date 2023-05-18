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
    [~, common_wav,common_ang, ~, pks_wav, pks_ang, add_wavs, add_angs]=img_spatio_freq(image,factor_wav,factor_angle); % retreive the spatial frequency of the image    
    % conduct gabor filtering
    if size(image,3)~= 1
        gray_img=im2gray(im2single(image));
    else
        gray_img=image;
    end

    % combine common and peaks 
    wavs_feat=cat(2,common_wav,pks_wav,add_wavs);
    ang_feat=cat(2,common_ang,pks_ang,add_angs);
    % remove na or inf values
    wavs_feat=wavs_feat(~(isnan(wavs_feat)|isinf(wavs_feat)));
    ang_feat=ang_feat(~(isnan(ang_feat)|isinf(ang_feat)));
    % convert angle to degree
    ang_feat=rad2deg(ang_feat);

    % create gabor filters
    g = gabor(wavs_feat,ang_feat);
    [mag_gabor,phase_gabor]=imgaborfilt(gray_img,g);

    % smooth each filtered image to remove local variations like it is in
    % MATLAB website: https://www.mathworks.com/help/images/ref/imsegkmeans.html
    for i = 1:length(g)
        sigma = 0.5*g(i).Wavelength;
        mag_gabor(:,:,i) = imgaussfilt(mag_gabor(:,:,i),3*sigma); 
    end
    montage(mag_gabor,"Size",[factor_angle factor_wav])

    nrows = size(image,1);
    ncols = size(image,2);
    [X,Y] = meshgrid(1:ncols,1:nrows);
    featureSet = cat(3,gray_img,mag_gabor,X,Y);

    L2 = imsegkmeans(featureSet,2,"NormalizeInput",true);
    C = labeloverlay(image,L2);
    figure;
    imshow(C)
    title("Labeled Image with Additional Pixel Information")
end