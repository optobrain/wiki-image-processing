% Created Date: March 9th, 2023
% Belong to: Leelab.ai
% Creator: Kuan-Min Lee
% Function Instruction:
% This function is created to compute an estimation of the spatio
% frequency of the tested image.
% Function Arguments:
% image: tested image (data size: (width image, length image, channel image)

function [common_freq, maximum_freq, minimum_freq]=img_spatio_freq(image)
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
    
    % show the image frequency plot
    figure(1);
    title("Fourier Transform Plot")
    imagesc(abs(fftshift(spatio_freq)))

    % plot the power spectral density plot
    spatio_freq_mag=abs(spatio_freq).^2/(wid_img*len_img);
    wid_rang=(1:wid_img);
    len_rang=(1:len_img);
    [wid_mat, len_mat]=ndgrid(wid_rang,len_rang);
    freqs_x=2*pi*(wid_mat-1)/len_img;
    freqs_y=2*pi*(len_mat-1)/wid_img;
    freqs=sqrt(freqs_x.^2+freqs_y.^2);
%     freqs=
    figure(2);
    title("Power Spectral Density Plot")
    plot(freqs,spatio_freq_mag);

    % find the most common frequency
    max_mag=max(spatio_freq_mag,[],'all');
    [com_x,com_y]=find(spatio_freq_mag==max_mag);
    % filter out only one frequency 
    % in the original output, there are two frequencies (one is the
    % original signal and the other is its complex conjugate). Only one is
    % needed.
    com_freq_x=(com_x(1)-1)/wid_img;
    com_freq_y=(com_y(1)-1)/len_img;
    % compute the frequency in x and y direction
    com_freq_x=2*pi*com_freq_x;
    com_freq_y=2*pi*com_freq_y;

    % find the maximum frequency
    [max_x,max_y]=find(spatio_freq,1,'last');
    max_freq_x=(max_x(1)-1)/wid_img;
    max_freq_y=(max_y(1)-1)/len_img;
    % compute the frequency in x and y direction
    max_freq_x=2*pi*max_freq_x;
    max_freq_y=2*pi*max_freq_y;

    % find the minimum frequency
    [min_x,min_y]=find(spatio_freq,1,'first');
    min_freq_x=(min_x(1)-1)/len_img;
    min_freq_y=(min_y(1)-1)/wid_img;
    % compute the frequency in x and y direction
    min_freq_x=2*pi*min_freq_x;
    min_freq_y=2*pi*min_freq_y;

    % check if the final frequency is larger than the base frequency: 2*pi/wid_img (need more clarification)
    thres_x=2*pi/wid_img;
    if com_freq_x<thres_x
        com_freq_x=0;
    end
    % check if the final frequency is larger than the base frequency: 2*pi/len_img (need more clarification)
    thres_y=2*pi/len_img;
    if com_freq_y<thres_y
        com_freq_y=0;
    end
    % check if the final frequency is larger than the base frequency: 2*pi/wid_img (need more clarification)
    if max_freq_x<thres_x
        max_freq_x=0;
    end
    % check if the final frequency is larger than the base frequency: 2*pi/len_img (need more clarification)
    if max_freq_y<thres_y
        max_freq_y=0;
    end
    % check if the final frequency is larger than the base frequency: 2*pi/wid_img (need more clarification)
    if min_freq_x<thres_x
        min_freq_x=0;
    end
    % check if the final frequency is larger than the base frequency: 2*pi/len_img (need more clarification)
    if min_freq_y<thres_y
        min_freq_y=0;
    end

    % return the frequencies
    common_freq=[com_freq_x com_freq_y];
    maximum_freq=[max_freq_x max_freq_y];
    minimum_freq=[min_freq_x min_freq_y];



end