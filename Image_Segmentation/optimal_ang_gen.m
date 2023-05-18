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

function optimal_angs=optimal_ang_gen(common_ang,peaks_ang, factor_angle)
    % check out if the input is empty
    % insert input parser for organizing the required and optional input
    p=inputParser;
    checkarray = @(x) ~isempty(x);
    checkinteger = @(x) isfinite(x);
    addRequired(p,"common_ang",checkarray);
    addRequired(p,"peaks_ang",checkinteger);
    addRequired(p,"factor_angle",checkinteger);
    parse(p,common_ang,peaks_ang,factor_angle);
    common_ang=p.Results.common_ang;
    peaks_ang=p.Results.peaks_ang;
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
        % find out how many feature wavelengths inside the feature set
        feat_angs=cat(2,common_ang,peaks_ang);
        feat_angs=feat_angs(~(isnan(feat_angs)|isinf(feat_angs)));
        % sort all wavelength from smallest to highest
        feat_angs=sort(feat_angs);
        % create a imaginary x array
        x=linspace(1,length(feat_angs),length(feat_angs));
        NewX=linspace(1,length(feat_angs),length(feat_angs)+factor_angle);
        % using linear interpolation to generate new point
        new_angs=interp1(x,feat_angs,NewX,'linear');
        new_angs=new_angs(~ismember(new_angs,common_ang));
        new_angs=new_angs(~ismember(new_angs,peaks_ang));

        % find out the element that is cloest to common wavelength
        [~,minInd]=mink(abs(new_angs-common_ang),factor_angle);
        % concatenate it back to feat_wavs
        optimal_angs=new_angs(minInd);
    end
end
