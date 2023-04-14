% Created Date: March 9th, 2023
% Belong to: Leelab.ai
% Creator: Kuan-Min Lee
% Function Instruction:
% This function is created to compute an estimation of the spatio
% frequency of the tested image.
% Function Arguments:
% image: tested image (data size: (width image, length image, channel image)

function [common_freq, common_ang]=img_spatio_freq(image)
    % check out if the input is empty
    % insert input parser for organizing the required and optional input
    p=inputParser;
    checkarray = @(x) ~isempty(x);
    addRequired(p,"image",checkarray);
    parse(p,image);
    image=p.Results.image;

    % find out the dimension of the image
    nx=size(image,1); % find out the element number in x direction
    ny=size(image,2); % find out the element number in y direction
    nz=size(image,3); % find out the element number in z direction
    % if the image is a color image, convert it to grayscale image
    if nz~=1
        image=rgb2gray(image);
    % if the image itself is already a grayscale one, stay the same
    else
        image=image;
    end
    
    % using the convention in https://www.mathworks.com/help/signal/ug/power-spectral-density-estimates-using-fft.html
    fs = 1;  % our x has 1.0 as an interval
    % conduct fast Fourier transform to transform the image to frequency
    % domain
    % conduct fast Fourier shift to centralize the component to the center
    % part of the matrix
    spatio_freq=fftshift(fft2(image));
    
    % Obtain the array for frequency in Fourier Transform domain
    fx=linspace(-fs/2+fs/nx,fs/2,nx); % x direction
    fy=linspace(-fs/2+fs/ny,fs/2,ny); % y direction
    
    % Obtain wavenumber array
    kx=2*pi*fx; % x direction 
    ky=2*pi*fy; % y direction

    % Obtain the Fourier Transform Plot
    figure(1);
    imagesc(abs(spatio_freq));

    % Obtain power spectral density information
    psd=(1/((fs*nx)*(fs*ny)))*abs(spatio_freq).^2;
    [mag_max] = max(psd, [], 'all');
    [im_fxMax,im_fyMax]=find(psd==mag_max);
    %=============================================
    
    % find the most common frequency
    fxMax=fx(im_fxMax-1);
    fyMax=fy(im_fyMax-1);
    % find the most common angular frequency
    kxMax=2*pi*fxMax;
    kyMax=2*pi*fyMax;
    % find the most common wavelength 
    wavxMax=1./fxMax;
    wavyMax=1./fyMax;
    % find the corresponding angle
    angMax = atan(fyMax/fxMax);
    % Obtain Power Spectral Density Plot
    figure(2);
    title("2D Power spectral density");
    imagesc(fx, fy, psd');
    [~,im]=max(psd); % find out index of the maximum value
    line(fx(im(1)), fy(im(2)), marker="o", color='c');  % mark the maximum by "o"
    axis image
    ax = gca;
    ax.YDir = "normal";
    ax.DataAspectRatio = [1 1 1];
    % x and y axes
    line(ax.XLim, [0 0], color='w');
    line([0 0], ax.YLim, color='w');  
    ax.YLabel.String = "\nu_y [/m]";
    ax.XLabel.String = ["\nu_x [/m]", ...
        sprintf("Max at nux=%.3f, kx=%.2f, lamX=%.1f", fx(im(1)), kx(im(1)), 2*pi/kx(im(1))), ...
        sprintf("and nuy=%.3f, ky=%.2f, lamY=%.1f", fy(im(2)), ky(im(2)), 2*pi/ky(im(2))), ...
        sprintf("and ang=%.2f [rad]", atan(ky(im(2))/kx(im(1))))];
        sgtitle([sprintf("True nux=%.3f, kx=%.2f, lamX=%.1f", fxMax, kxMax, wavxMax), ...
        sprintf("and nuy=%.3f, ky=%.2f, lamY=%.1f", fyMax, kyMax, wavyMax), ...
        sprintf("and ang=%.2f [rad]", angMax)]);

    % check if the final frequency is larger than the base frequency: 2*pi/wid_img (need more clarification)
    thres_x=2*pi/nx;
    if fxMax<thres_x
        fxMax=0;
    end
    % check if the final frequency is larger than the base frequency: 2*pi/len_img (need more clarification)
    thres_y=2*pi/ny;
    if fyMax<thres_y
        fyMax=0;
    end

    % return the frequencies
    common_freq=[fxMax fyMax];
    common_ang=angMax;

end