% Created Date: March 9th, 2023
% Belong to: Leelab.ai
% Creator: Kuan-Min Lee
% Function Instruction:
% This function is created to compute an estimation of the spatio
% frequency of the tested image.
% Function Arguments:
% image: tested image (data size: (width image, length image, channel image)

function [common_freq, common_ang, ...
          maximum_freq, maximum_freq_ang,...
          minimum_freq, minimum_freq_ang]=img_spatio_freq(image)
    % check out if the input is empty
    % insert input parser for organizing the required and optional input
    p=inputParser;
    checkarray = @(x) ~isempty(x);
    addRequired(p,"image",checkarray);
    parse(p,image);
    image=p.Results.image;

    % find out the dimension of the image
    nx=size(image,1);
    ny=size(image,2);
    chn_img=size(image,3);
    % if the image is a color image, convert it to grayscale image
    if chn_img~=1
        image=rgb2gray(image);
    % if the image itself is already a grayscale one, stay the same
    else
        image=image;
    end

    % conduct fourier transform on image
%     spatio_freq=fft2(image);
%     spatio_freq=fftshift(spatio_freq);
    
    % using the convention in https://www.mathworks.com/help/signal/ug/power-spectral-density-estimates-using-fft.html
    fs = 1/1.0;  % our x has 1.0 as an interval
    spatio_freq=fftshift(fft2(image));
%     spatio_freq=fft2(image);
    
%     spatio_freq = spatio_freq(nx/2:nx,:);  % take the area for kx>0
    spatio_freq = (1/(fs*nx*ny)) * abs(spatio_freq).^2;
%     spatio_freq(2:end-1) = 2*spatio_freq(2:end-1);
    % show the image frequency plot
    x=(1:nx);
    x=x-1;
    x=x/ny;
    x=x-0.5;
    y=(1:ny);
    y=y-1;
    y=y/nx;
    y=y-0.5;
    kx = 2*pi * x;
    ky = 2*pi * y;
    kx = kx((nx/2+1):nx);

%     freq = 0:fs/length(x):fs/2;
    kx = 0:fs/nx:fs/2;  % when you have the sampling freq. fs, the maximum freq you can inspect with FFT is fs/2.
    kx = -fs/2:fs/nx:fs/2;
    kx = kx(2:end);
    ky = -fs/2:fs/ny:fs/2;
    ky = ky(2:end);  % ky(1) = -kyMax is omitted in fft

    figure;
    title("2D Power spectral density")
    imagesc(kx, ky, spatio_freq')
    axis image
    ax = gca;
    ax.YDir = "normal";
    xlabel("k_x")
    ylabel("k_y")


    % plot the power spectral density
    spatio_freq_mag=abs(spatio_freq).^2/(nx*ny);
%     wid_rang=(1:wid_img);
%     len_rang=(1:len_img);
%     [wid_mat, len_mat]=ndgrid(wid_rang,len_rang);
%     wid_mat=wid_mat-1; % subtract every element in horizontal direction by 1 
%     wid_mat=wid_mat/len_img; % divide every element in horizontal direction by the length of the image
%     len_mat=len_mat-1; % subtract every element in vertical direction by 1
%     len_mat=len_mat/wid_img; % divide every element in vertical direction by the width of the image
%     % centralize the frequency scale
%     wid_mat=wid_mat-0.5;
%     len_mat=len_mat-0.5;
%     % calculate the overall frequency
%     freqs_x=2*pi*wid_mat;
%     freqs_y=2*pi*len_mat;
%     freqs=sqrt(freqs_x.^2+freqs_y.^2);
    [gkx, gky] = ndgrid(kx, ky);
    k = sqrt(gkx.^2 + gky.^2);
    kSort = k(:);
    [kSort, is] = sort(kSort);
    spatio_freq_mag_sort = spatio_freq_mag(:);
    spatio_freq_mag_sort = spatio_freq_mag_sort(is);
   
    figure;
    title("Power Spectral Density Plot")
    plot(kSort, spatio_freq_mag_sort);

    kx1 = kx(end/2+1:end);
    spatio_freq_mag1 = spatio_freq_mag(:,end/2+1:end);
    figure;
    title("2D Fourier Transform Plot for positive kx and ky")
    imagesc(kx1, ky, abs(spatio_freq_mag1))
    ax = gca;
    ax.YDir = 'normal';
    xlabel("k_x")
    ylabel("k_y")


    max_mag = max(spatio_freq_mag1, [], 'all');
    [ikyMax, ikxMax] = find(spatio_freq_mag1 == max_mag);
    kxMax = kx1(ikxMax);
    kyMax = ky1(ikyMax);
    kMax = sqrt(kxMax^2 + kyMax^2)
    angMax = atan(kyMax/kxMax)





    % find the most common frequency
    max_mag=max(spatio_freq_mag,[],'all');
    [com_x,com_y]=find(spatio_freq_mag==max_mag);
    % calculate the most common frequency
    % The center point will be located in between the middle two most
    % common frequency.
    % Therefore, the most common frequency can be calculated as:
    if numel(com_x)>1
        half_com=ceil(numel(com_x)/2);
        com_freq_x=abs(flip(com_x(1:half_com))-com_x(half_com+1:end))/2;
        com_freq_x=com_freq_x/ny;
        com_freq_y=abs(flip(com_y(1:half_com))-com_y(half_com+1:end))/2;
        com_freq_y=com_freq_y/nx;
        % find the most common angle for the frequency    
        re_comp=real(spatio_freq(com_x(half_com+1:end),com_y(half_com+1:end)));
        im_comp=imag(spatio_freq(com_x(half_com+1:end),com_y(half_com+1:end)));
        com_ang=atan(im_comp/re_comp);
    else
        com_freq_x=com_x(1)-(ny/2);
        com_freq_x=com_freq_x/ny;
        com_freq_y=com_y(1)-(nx/2);
        com_freq_y=com_freq_y/nx;
        re_comp=real(spatio_freq(com_x(1),com_y(1)));
        im_comp=imag(spatio_freq(com_x(1),com_y(1)));
        com_ang=atan(im_comp/re_comp);
    end
    % compute the frequency in x and y direction
    com_freq_x=2*pi*com_freq_x;
    com_freq_y=2*pi*com_freq_y;


    % find the maximum frequency
    [max_x,max_y]=find(spatio_freq_mag,1,'last');
    max_freq_x=(max_x(1)-1)/ny;
    max_freq_y=(max_y(1)-1)/nx;
    max_freq_x=max_freq_x-0.5;
    max_freq_y=max_freq_y-0.5;
    % calculate the angle for the maximum frequency
    re_comp=real(spatio_freq(max_x(1),max_y(1)));
    im_comp=imag(spatio_freq(max_x(1),max_y(1)));
    max_ang=atan(im_comp/re_comp);
    % compute the frequency in x and y direction
    max_freq_x=2*pi*max_freq_x;
    max_freq_y=2*pi*max_freq_y;

    % find the minimum frequency
    [min_x,min_y]=find(spatio_freq_mag,1,'first');
    min_freq_x=(min_x(1)-1)/ny;
    min_freq_y=(min_y(1)-1)/nx;
    min_freq_x=min_freq_x-0.5;
    min_freq_y=min_freq_y-0.5;
    % calculate the angle for the maximum frequency
    re_comp=real(spatio_freq(min_x(1),min_y(1)));
    im_comp=imag(spatio_freq(min_x(1),min_y(1)));
    min_ang=atan(im_comp/re_comp);
    % compute the frequency in x and y direction
    min_freq_x=2*pi*min_freq_x;
    min_freq_y=2*pi*min_freq_y;


    % check if the final frequency is larger than the base frequency: 2*pi/wid_img (need more clarification)
    thres_x=2*pi/nx;
    if com_freq_x<thres_x
        com_freq_x=0;
    end
    % check if the final frequency is larger than the base frequency: 2*pi/len_img (need more clarification)
    thres_y=2*pi/ny;
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
    common_ang=com_ang;
    maximum_freq=[max_freq_x max_freq_y];
    maximum_freq_ang=max_ang;
    minimum_freq=[min_freq_x min_freq_y];
    minimum_freq_ang=min_ang;



end