% Created Date: April 7th, 2023
% Belong to: Leelab.ai
% Creator: Kuan-Min Lee
% Function Instruction:
% This function is created to compute the optimal angle range for
% gabor filter function from MATLAB library
% Function Arguments:
% common_ang: the most common wavelengths obtain from
% freq_wave_convert.m function 
% (data size: single integer or array with size of (num_commonwavelength,1))
% factor_angle: factor of angle obatined from the input from
% optimal_gaborfilt.m function 
% (data size: single integer)

function optimal_angs=optimal_ang_gen(common_ang,max_freq_x,max_freq_y, min_freq_x, min_freq_y, factor_angle)
    % check out if the input is empty
    % insert input parser for organizing the required and optional input
    p=inputParser;
    checkarray = @(x) ~isempty(x);
    checkinteger = @(x) isfinite(x);
    addRequired(p,"common_ang",checkarray);
    addRequired(p,"max_freq_x",checkinteger);
    addRequired(p,"max_freq_y",checkinteger);
    addRequired(p,"min_freq_x",checkinteger);
    addRequired(p,"min_freq_y",checkinteger);
    addRequired(p,"factor_angle",checkinteger);
    parse(p,common_ang,max_freq_x,max_freq_y, min_freq_x, min_freq_y,factor_angle);
    common_ang=p.Results.common_ang;
    max_freq_x=p.Results.max_freq_x;
    max_freq_y=p.Results.max_freq_y;
    min_freq_x=p.Results.min_freq_x;
    min_freq_y=p.Results.min_freq_y;
    factor_angle=p.Results.factor_angle;

    % check the number of common angle
    % if there are multiple common angles conduct one way of computing
    % wavelength ranges
    if numel(common_ang)~=1
        % figure out the number of common angle
        num_commonang=numel(common_ang);
        % create variable for storing wave factors for each wavelength
        % range
        optimal_ang=[];        
        % sort common wavelength array
        common_ang=sort(common_ang);
        % calculate new factor for each wave range
        for i_commonang=1:num_commonang-1
            % pick up the current and next wavelength values
            first=common_ang(i_commonang);
            second=common_ang(i_commonang);
            % calculate the range between these two
            range=second-first;
            % create grids
            new_factor=factor_angle/(num_commonang-1);
            grid_size=range/new_factor;
            % create wavelength range
            ang_rang=first:grid_size:second;
            % store it into optimal wave array
            optimal_angs=cat(1,optimal_ang,ang_rang);
        end
    % if there is only one common angle conduct one way of computing
    % wavelength ranges
    else
        % create variable for storing wave factors for each wavelength
        % range
        max_ang=atan(max_freq_y/min_freq_x);
        min_ang=atan(min_freq_y/max_freq_x);
        factormax=factor_angle*(max_ang-common_ang)/(max_ang-min_ang);
        factormin=factor_angle*(common_ang-min_ang)/(max_ang-min_ang);
        commonTomax=common_ang:(max_ang-common_ang)/(factormax):max_ang;
        commonTomin=min_ang:(common_ang-min_ang)/(factormin):common_ang;
        optimal_angs=[commonTomin commonTomax];
    end
end
