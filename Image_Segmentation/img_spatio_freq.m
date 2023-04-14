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
    nx=size(image,1); % find out the element number in x direction
    ny=size(image,2); % find out the element number in y direction
    nz=size(image,3); % find out the element number in z direction
    % if the image is a color image, convert it to grayscale image
    if chn_img~=1
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
    
    %% The below part needs modification
    % Obtain the array for space (x and y values in Fourier Transform)
    % x direction
    x=(1:nx); % generate the number of samples in x direction
    x=x-1; % subtract every element by 1
    x=x./fs; % divice every element in x by the sampling interval
    % y direction
    y=(1:ny); % generate the number of samples in x direction
    y=y-1; % subtract every element by 1
    y=y./fs; % divice every element in y by the sampling interval
    % create grid for array of space
    [gx,gy]=ndgrid(x,y);

    % Obtain the array for frequency in Fourier Transform domain
    fx=linspace(-fs/2+fs/nx,fs/2,nx); % x direction
    fy=linspace(-fs/2+fs/ny,fs/2,ny); % y direction

    % Obtain power spectral density information
    psd=(1/((fs*nx)*(fs*ny)))*abs(spatio_freq).^2;

    % Obtain the Fourier Transform Plot
    figure(1);
    imagesc(abs(spatio_freq));

    % Obtain Power Spectral Density Plot
    figure(2);
    title("2D Power spectral density");
    imagesc(fx, fy, spatio_freq');
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
        sprintf("Max at nux=%.3f, kx=%.2f, lamX=%.1f", nux(im(1)), kx(im(1)), 2*pi/kx(im(1))), ...
        sprintf("and nuy=%.3f, ky=%.2f, lamY=%.1f", nuy(im(2)), ky(im(2)), 2*pi/ky(im(2))), ...
        sprintf("and ang=%.2f [rad]", atan(ky(im(2))/kx(im(1))))];
        sgtitle([sprintf("True nux=%.3f, kx=%.2f, lamX=%.1f", nux1, kx1, lamX), ...
        sprintf("and nuy=%.3f, ky=%.2f, lamY=%.1f", nuy1, ky1, lamY), ...
        sprintf("and ang=%.2f [rad]", ang1)]);

    % plot the power spectral density
    spatio_freq_mag=abs(spatio_freq).^2/(nx*ny);

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