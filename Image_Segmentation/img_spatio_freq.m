% Created Date: March 9th, 2023
% Belong to: Leelab.ai
% Creator: Kuan-Min Lee
% Function Instruction:
% This function is created to compute an estimation of the spatio
% frequency of the tested image.
% Function Arguments:
% image: tested image (data size: (width image, length image, channel image)

function common_freq=img_spatio_freq(image)
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
    freqs=wid_mat.*len_mat;
    figure(2);
    title("Power Spectral Density Plot")
    plot(freqs,spatio_freq_mag);
    % find the most common frequency domain
    max_mag=max(spatio_freq_mag,[],'all');
    [x,y]=find(spatio_freq_mag==max_mag);

    % filter out only one frequency 
    % in the original output, there are two frequencies (one is the
    % original signal and the other is its complex conjugate). Only one is
    % needed.
    freq_x=x(1)/wid_img;
    freq_y=y(1)/len_img;
    % compute the frequency in x and y direction
    freq_x=2*pi*freq_x;
    freq_y=2*pi*freq_y;

    % check if the final frequency is larger than the base frequency: 2*pi/wid_img (need more clarification)
    thres_x=2*pi/wid_img;
    if freq_x<=thres_x
        freq_x=0;
    end
    % check if the final frequency is larger than the base frequency: 2*pi/len_img (need more clarification)
    thres_y=2*pi/len_img;
    if freq_y<=thres_y
        freq_y=0;
    end

    common_freq=[freq_x freq_y];



end