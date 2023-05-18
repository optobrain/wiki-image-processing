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
    addOptional(p,"peaks_wavelength",[]);
    addRequired(p,"factor_wav",checkinteger);
    parse(p,common_wavelength,peaks_wavelength,factor_wav);
    common_wavelength=p.Results.common_wavelength;
    peaks_wavelength=p.Results.peaks_wavelength;
    factor_wav=p.Results.factor_wav;

    % check how many common frequencies 
    % if there are multiple common frequencies conduct one way of computing
    % wavelength ranges
    if numel(common_wavelength)~=1     
        % calculate the number of common wavelength
        num_comm=numel(common_wavelength);
        % calculate the mean wavelength of the most common wavelength
        mean_com_wav=min(common_wavelength,[],"all");
        % get the log base additional wavelength 
        add_wav = mean_com_wav.^(0:factor_wav);
        % output additional wavelength
        optimal_wav=cat(2,common_wavelength,peaks_wavelength,add_wav);

    % if there is only one common frequencies conduct one way of computing
    % wavelength ranges
    else 
        % find out how many feature wavelengths inside the feature set
        feat_wavs=cat(2,common_wavelength,peaks_wavelength);
        feat_wavs=feat_wavs(~(isnan(feat_wavs)|isinf(feat_wavs)));
        % sort all wavelength from smallest to highest
        feat_wavs=sort(feat_wavs);
        % create a imaginary x array
        x=linspace(1,length(feat_wavs),length(feat_wavs));
        NewX=linspace(1,length(feat_wavs),length(feat_wavs)+factor_wav);
        % using linear interpolation to generate new point
        new_wavs=interp1(x,feat_wavs,NewX,'linear');
        new_wavs=new_wavs(~ismember(new_wavs,common_wavelength));
        new_wavs=new_wavs(~ismember(new_wavs,peaks_wavelength));
        % find out the element that is cloest to common wavelength
        [~,minInd]=mink(abs(new_wavs-common_wavelength),factor_wav);

        optimal_wav=new_wavs(minInd);
        
    end


end