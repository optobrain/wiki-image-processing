% Created Date: March 9th, 2023
% Belong to: Leelab.ai
% Creator: Kuan-Min Lee
% Function Instruction:
% This function is created to compute an estimation of the spatio
% frequency of the tested image.
% Function Arguments:
% image: tested image (data size: (width image, length image, channel image)

function highest_freq=img_spatio_freq(image)
    % check out if the input is empty
    % insert input parser for organizing the required and optional input
    p=inputParser;
    checkarray = @(x) ~isempty(x);
    addRequired(p,"image",checkarray);
    parse(p,image);
    image=p.Results.image;

    % find out the dimension of the image
    wid_img=size(image,1);
    len_img=size(image,2);
    chn_img=size(image,3);
    % if the image is a color image, convert it to grayscale image
    if chn_img~=1
        image=rgb2gray(image);
    % if the image itself is already a grayscale one, stay the same
    else
        image=image;
    end

    % conduct fourier transform on image
    spatio_freq=fft2(image);
    spatio_freq=fftshift(spatio_freq);
    
    % show the image frequency plot
    figure(1);
    imagesc(abs(spatio_freq))

    % plot the power spectral density plot
    spatio_freq=abs(spatio_freq).^2/(wid_img*len_img);
    wid_rang=(1:wid_img);
    len_rang=(1:len_img);
    [wid_mat, len_mat]=ndgrid(wid_rang,len_rang);
    freqs=wid_mat.*len_mat;
    figure(2);
    plot(freqs,spatio_freq);

    max_mag=max(spatio_freq);
    [x,y]=find(spatio_freq==max_mag);
    highest_freq=freqs(x,y);

    % return the frequency with the highest magnitude of fourier
    % coefficient



end