% Created Date: March 9th, 2023
% Belong to: Leelab.ai
% Creator: Kuan-Min Lee
% Function Instruction:
% This function is created to compute an estimation of the spatio
% frequency of the tested image.
% Function Arguments:
% image: tested image (data size: (width image, length image, channel
% image))

function [common_freq, common_wav,common_ang, pks_freq, pks_wav, pks_ang]=img_spatio_freq(image,factor_wav,factor_ang)
    % check out if the input is empty
    % insert input parser for organizing the required and optional input
    p=inputParser;
    checkarray = @(x) ~isempty(x);
    addRequired(p,"image",checkarray);
    parse(p,image);
    image=p.Results.image;

    % find out the dimension of the image
    % notice that the x here is the horizontal direction and the y here is
    % the vertical direction. therefore, x is 2 and y is 1.
    nx=size(image,2); % find out the element number in x direction
    ny=size(image,1); % find out the element number in y direction
    nz=size(image,3); % find out the element number in z direction
    % if the image is a color image, convert it to grayscale image
    if nz~=1
        image=rgb2gray(image);
    % if the image itself is already a grayscale one, stay the same
    else
        image=image;
    end

    % normalize image pixel 
    max_pix=max(image,[],'all');
    min_pix=min(image,[],'all');
    image=2*(image-min_pix)./(max_pix-min_pix)-1;
    
    % using the convention in https://www.mathworks.com/help/signal/ug/power-spectral-density-estimates-using-fft.html
    fs = 1;  % our x has 1.0 as an interval
    % conduct fast Fourier transform to transform the image to frequency
    % domain
    % conduct fast Fourier shift to centralize the component to the center
    % part of the matrix
    spatio_freq=fftshift(fft2(image));
    % compute the magnitude of spatial frequency plot generated from spatial frequency
    mag_spatio_freq=abs(spatio_freq);

    % Obtain the array for frequency in Fourier Transform domain
    fx = linspace(-fs/2, fs/2-fs/nx, nx); % x direction 
    fy = linspace(-fs/2, fs/2-fs/ny, ny); % y direction

    % Obtain spatial frequency matrix
    [gfy,gfx] = ndgrid(fy,fx);
    spatial_freq=sqrt(gfx.^2+gfy.^2);

    % Obtain wavenumber array
    kx=2*pi*fx; % x direction 
    ky=2*pi*fy; % y direction
    
    % Obtain the Fourier Transform Plot
    % in your case, we should NOT have the transpose (because of below)
    figure;   colormap(jet)
    psd_dB = 10*log10(mag_spatio_freq/max(mag_spatio_freq(:)));
    imagesc(fx,fy,psd_dB)  % imagesc() assumes mag_spatio_freq(ky,kx) but receives imagesc(kx,ky,mag..(ky,kx))
    % that's why, I usually set 2D array to be f(x,y), and then use
    % imagesc(x,y,f')
    cb = colorbar;
    cb.Label.String = "Power (dB)";
    axis image;
    set(gca,'ydir','normal')
    axis image
    ax = gca;
    set(gca,'clim',[-50 0])
    ax.YDir = "normal";
    ax.DataAspectRatio = [1 1 1];

    % Obtain power spectral density information
    psd=(1/((fs*nx)*(fs*ny))).*abs(spatio_freq).^2;
    
    % Obtain the index of the maximum magnitude
    [mag_max] = max(psd, [], 'all');
    [im_fyMax,im_fxMax]=find(psd==mag_max);
    % check if the frequency is in only one direction
    % if there's only x direction frequency exists, chuck off the matrix in
    % x direction
    testfx=im_fxMax-nx/2-1;
    testfy=im_fyMax-ny/2-1;
    % if there's only x direction frequency exists, chuck off the matrix in
    % x direction
    if ~all(testfy(:),'all')
        test_psd=psd(:,nx/2+1:end);
        [mag_max] = max(test_psd, [], 'all');
        [im_fyMax,im_fxMax]=find(test_psd==mag_max);
        im_fxMax=im_fxMax+nx/2;
    % if there's only y direction frequency exists, chuck off the matrix in
    % y direction
    elseif ~all(testfx(:),'all')
        test_psd=psd(ny/2+1:end,:);
        [mag_max] = max(test_psd, [], 'all');
        [im_fyMax,im_fxMax]=find(test_psd==mag_max);
        im_fyMax=im_fyMax+ny/2;
    % set the default mode as chucking off along the x direction
    else
        test_psd=psd(ny/2+1:end,:);
        [mag_max] = max(test_psd, [], 'all');
        [im_fyMax,im_fxMax]=find(test_psd==mag_max);
        im_fyMax=im_fyMax+ny/2;
    end

    % find the most common frequency
    fxMax=fx(im_fxMax);
    fyMax=fy(im_fyMax);
    % find the most common angular frequency
    kxMax=2*pi*fxMax;
    kyMax=2*pi*fyMax;
    % find the most common wavelength 
    wavxMax=1./fxMax;
    wavyMax=1./fyMax;
    % compute the most common wavelength 
    wavMax=sqrt(wavxMax.^2+wavyMax.^2);
    % find the corresponding angle
    angMax = atan(fyMax/fxMax);
    if isnan(angMax)
        angMax=0;
    end

    % find the top 10 peaks frequency in fourier transform frequency
    mag_size=size(mag_spatio_freq);
    mag_spatio_freq_t=mag_spatio_freq'; % take the transpose of the matrix
    [pks_x,locs_x]=findpeaks(double(mag_spatio_freq(:))); % find peaks along x direction
    [pks_y,locs_y]=findpeaks(double(mag_spatio_freq_t(:))); % find peaks along y direction
    mag_size=size(mag_spatio_freq);
    ind=intersect(locs_x,locs_y); % get the peaks that are present in both x and y directions
    [y_coords,x_coords]=ind2sub(mag_size,ind); % get the correpsonding 2D coordinates
    inter_pks=mag_spatio_freq(sub2ind(size(mag_spatio_freq),y_coords,x_coords));
    [sort_inter_pks, pks_ind]=sort(inter_pks,'descend'); % sort the peak values in descending order
    yTop=y_coords(pks_ind);
    xTop=x_coords(pks_ind);
    ys=yTop(1:min(length(yTop),factor_wav-length(wavMax)));
    xs=xTop(1:min(length(xTop),factor_wav-length(wavMax)));
    % calculate the correpsonding spatial frequencies
    fx_pks=fx(xs);
    fy_pks=fy(ys);
    % find the peak wavelength 
    wavxPks=1./fx_pks;
    wavyPks=1./fy_pks;
    wavPks=sqrt(wavxPks.^2+wavyPks.^2);
    % calculate peak angle
    angPks=atan(fy_pks/fx_pks);
    angPks=angPks(1:min(length(angPks),factor_ang-length(angPks)));

    % Obtain Power Spectral Density Plot
    figure;
    imagesc(fx,fy,psd)
    line(fxMax, fyMax, marker="o", color='c');  % mark the maximum by "o"


    figure(2);
    title("2D Power spectral density");
    imagesc(fx, fy, psd);  % psd(fy,fx) so we don't need transpose
    [~,im]=max(psd); % find out index of the maximum value
    line(fxMax, fyMax, marker="o", color='c');  % mark the maximum by "o"
    line(fx_pks,fy_pks,marker="+", color='c'); % mark out other peaks by "+"
    axis image
    ax = gca;
    ax.YDir = "normal";
    ax.DataAspectRatio = [1 1 1];
    % x and y axes
    line(ax.XLim, [0 0], color='w');
    line([0 0], ax.YLim, color='w');  
    ax.YLabel.String = "\nu_y [/m]";
    ax.XLabel.String = ["\nu_x [/m]", ...
        sprintf("Max at nux=%.3f, kx=%.2f, lamX=%.1f", fxMax, kxMax, 2*pi./kxMax), ...
        sprintf("and nuy=%.3f, ky=%.2f, lamY=%.1f", fyMax, kyMax, 2*pi./kyMax), ...
        sprintf("and ang=%.2f [rad]", atan(kyMax./kxMax))];

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
    common_wav=wavMax;
    % return the peak frequencies
    pks_freq=[fx_pks fy_pks];
    pks_ang=angPks;
    pks_wav=wavPks;


end