% Created Date: April 7th, 2023
% Belong to: Leelab.ai
% Creator: Kuan-Min Lee
% Function Instruction:
% This function is created to compute the optimal wavelength range for
% gabor filter function from MATLAB library
% Function Arguments:
% common_wavelength: the most common wavelengths obtain from
% freq_wave_convert.m function 
% (data size: single integer or array with size of (num_commonwavelength,1))
% max_freq_wavelength: the wavelength for maximum frequency obtained from
% freq_wave_converter.m function (data size: single integer)
% min_freq_wavelength: the wavelength for minimum frequency obtained from
% freq_wave_converter.m function (data size: single integer)
% factor_wav: factor of wavelength obatined from the input from
% optimal_gaborfilt.m function 
% (data size: single integer)

function optimal_wav=optimal_wav_gen(common_wavelength,peaks_wavelength,factor_wav)
    % check out if the input is empty
    % insert input parser for organizing the required and optional input
    p=inputParser;
    checkarray = @(x) ~isempty(x);
    checkinteger = @(x) isfinite(x) && x == floor(x);
    addRequired(p,"common_wavelength",checkarray);
    addRequired(p,"max_freq_wavelength",checkarray);
    addRequired(p,"min_freq_wavelength",checkarray);
    addRequired(p,"factor_wav",checkinteger);
    parse(p,common_wavelength,max_freq_wavelength,min_freq_wavelength,factor_wav);
    common_wavelength=p.Results.common_wavelength;
    max_freq_wavelength=p.Results.max_freq_wavelength;
    min_freq_wavelength=p.Results.min_freq_wavelength;
    factor_wav=p.Results.factor_wav;

    % check how many common frequencies 
    % if there are multiple common frequencies conduct one way of computing
    % wavelength ranges
    if numel(common_wavelength)~=1
        % figure out the number of common wavelength
        num_commonwave=numel(common_wavelength);
        % create variable for storing wave factors for each wavelength
        % range
        optimal_wav=[];        
        % sort common wavelength array
        common_wavelength=sort(common_wavelength);
        % calculate new factor for each wave range
        for i_commonwave=1:num_commonwave-1
            % pick up the current and next wavelength values
            first=common_wavelength(i_commonwave);
            second=common_wavelength(i_commonwave);
            % calculate the range between these two
            range=second-first;
            % create grids
            new_factor=factor_wav/(num_commonwave-1);
            grid_size=range/new_factor;
            % create wavelength range
            wav_rang=first:grid_size:second;
            % store it into optimal wave array
            optimal_wav=cat(1,optimal_wav,wav_rang);
        end
    % if there is only one common frequencies conduct one way of computing
    % wavelength ranges
    else 
        % distribute the wave factor between the range of common and maximum
        % wavelength and common and minimum wavelength
        dist_commin=min_freq_wavelength-common_wavelength;
        dist_commax=common_wavelength-max_freq_wavelength;
        fact_commax=dist_commin/(dist_commin+dist_commax)*factor_wav;
        fact_commax=round(fact_commax);
        fact_commin=factor_wav-fact_commax;
        if dist_commin==0
            dist_commin=1;
        end

        if fact_commax==0
            fact_commax=1;
        end
        if fact_commin==0
            fact_commin=1;
        end
        % make up the wave grids 
        % note that the gabbor filter function requires the wavelengthes to be
        % always larger or equal to 2
        grid_commax=max([2,max_freq_wavelength],[],'all'):(dist_commax)/fact_commax:max([2,common_wavelength],[],'all');
        grid_commin=max([2,common_wavelength],[],'all'):(dist_commin)/fact_commin:max([2,min_freq_wavelength],[],'all');
        optimal_wav=[grid_commax, grid_commin];
    end


end