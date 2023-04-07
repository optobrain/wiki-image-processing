function optimal_wav=optimal_wav_gen(common_wavelength,max_freq_wavelength,min_freq_wavelength)
    
    % computing the optimal wavelengthes for gabor filters
    % distribute the wave factor between the range of common and maximum
    % wavelength and common and minimum wavelength
    dist_commax=min_freq_wavelength-common_wavelength;
    dist_commin=common_wavelength-max_freq_wavelength;
    fact_commax=dist_commin/(dist_commin+dist_commax)*factor_wav;
    fact_commax=round(fact_commax);
    fact_commin=factor_wav-fact_commax;
    % make up the wave grids 
    % note that the gabbor filter function requires the wavelengthes to be
    % always larger or equal to 2
    grid_commax=max([2,max_freq_wavelength],[],'all'):max([2,common_wavelength],[],'all'):(dist_commax)/fact_commax;
    grid_commin=max([2,common_wavelength],[],'all'):(dist_commin)/fact_commin:max([2,min_freq_wavelength],[],'all');
    grid_wavelengths=[grid_commax, grid_commin];


end