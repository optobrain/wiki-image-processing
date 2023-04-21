% Created Date: March 9th, 2023
% Belong to: Leelab.ai
% Creator: Kuan-Min Lee
% Function Instruction:
% This function is created to compute a conversion for frequency to
% wavelength for usage for gabor filter function for MATLAB
% Function Arguments:
% freq: computed frequency from img_spatio_freq.m function
function wavelength=freq_wave_converter(image,freq)
    % check out if the input is empty
    % insert input parser for organizing the required and optional input
    p=inputParser;
    checkinput = @(x) ~isempty(freq);
    checkinput2= @(x) ~isempty(image);
    addRequired(p,"image",checkinput2);
    addRequired(p,"freq",checkinput);
    parse(p,image,freq);
    image=p.Results.image;
    freq=p.Results.freq;

    % conduct frequency to wavelength conversion
    num_freq=size(freq,2);
    wavelength=zeros(num_freq,1);
    for i_freq=1:num_freq
        if freq(i_freq)~=0
            wavelength(i_freq)=(1./freq(i_freq));
        else
            if i_freq==1
                wavelength(i_freq)=size(image,2);
            else
                wavelength(i_freq)=size(image,1);
            end
        end
    end
    
end