% Created Date: March 9th, 2023
% Belong to: Leelab.ai
% Creator: Kuan-Min Lee
% Function Instruction:
% This function is created to compute an estimation of the spatio
% frequency of the tested image.
% Function Arguments:
% image: tested image (data size: (width image, length image, channel image)

function spatio_freq=img_spatio_freq(image)
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

    % if the image is colored, change to grayscale
    if chn_img~=1
        gray_img=rgb2gray(image);
    else
        gray_img=image;
    end

    % create arrays for storing row and column frequencies
    row_freqs=size(1,wid_img);
    col_freqs=size(1,len_img);

    % retrieve the image spatio frequency along y direction
    for i_wid=1:wid_img
        % get the current tested row
        curr_row=gray_img(i_wid,:);
        % find the local maximums of the data points
        loc_maxs=islocalmax(curr_row);
        % find out the positions of local maximums
        loc_maxs_pos=find(loc_maxs);

        % compute the spatial frequency of the image
        % if the local maximum position contains no information,
        % set the image spatioa frequency along the row as the length size
        if isempty(loc_maxs_pos)
            row_freqs(1,i_wid)=len_img;
        % otherwise, calculate the difference between every adjacent element
        else
            % calculate the difference between adjecent element
            ind_diff=diff(loc_maxs_pos);
            % calculate the mean of the difference 
            mean_diff=mean(ind_diff,'all');
            row_freqs(1,i_wid)=mean_diff;
        end
    end
    % calculate the mean of the row frequency
    mean_row_freq=mean(row_freqs,'all');

    % retrieve the image spatio frequency along x direction
    for i_len=1:len_img
        % get the current tested row
        curr_col=gray_img(:,i_len);
        % find the local maximums of the data points
        loc_maxs=islocalmax(curr_col);
        % find out the positions of local maximums
        loc_maxs_pos=find(loc_maxs);

        % compute the spatial frequency of the image
        % if the local maximum position contains no information,
        % set the image spatioa frequency along the row as the length size
        if isempty(loc_maxs_pos)
            col_freqs(1,i_len)=wid_img;
        % otherwise, calculate the difference between every adjacent element
        else
            % calculate the difference between adjecent element
            ind_diff=diff(loc_maxs_pos);
            % calculate the mean of the difference 
            mean_diff=mean(ind_diff,'all');
            col_freqs(1,i_wid)=mean_diff;
        end
    end
    % calcualte the mean of the column frequency
    mean_col_freq=mean(col_freqs,'all');

    % calculate the spatio frequency
    spatio_freq=sqrt(mean_row_freq^2+mean_col_freq^2);

end