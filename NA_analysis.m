function NA_analysis(settings)
%settings:
%  datasetname: string, name for the dataset
%  inputdir: string, directory where the relevant files are found - NO
%        slash at the end
%  outputdir: string, directory where calculated files are saved - NO slash
%        at the end
%  pseudo: struct with fields:
%        prestim: indices in the epoched data for prestim pseudotrial
%        poststim: indices in the epoched data for poststim pseudotrial
%  real: struct with fields:
%        prestim: indices in the epoched data for prestim real trial
%        poststim: indices in the epoched data for poststim real trial
%  aucindex: vector of data indices for computation of the TTV, ERSP, and
%        ITC indices
%  datasetinfo: a structure with the labels and channel/gradiometer
%        locations for the data set
%  datatype: 'EEG', 'MEG' or 'ECoG'
%  layout: .lay file or structure for plotting if MEG data, or EEGLAB
%        chanlocs structure for EEG data
%  steps: cell array containing which steps of the analysis to do
%        (default = {'all'})
%  srate: sample rate of the time-frequency data (default = 200)
%  units: 'prcchange', 'log', 'raw', or 'zscore' (default = 'prcchange')
%  files: the input to 'dir' to select what files to use (default = '*.mat'
%        for ECoG/MEG data, '*.set' for EEG data)
%  pool: the maximum parallel pool size (default = 24)
%  tfparams: a structure with fields relating to the frequency decomposition
%        method: 'hilbert', 'wavelet', 'fft', or 'irasa'
%        fbands: cell array of frequency bands - use [] for broadband
%        fbandnames: names of the frequency bands of interest
%        condition: a number or numbers that indicate which condition to 
%        include. These numbers should be found in the data.trialinfo field
%        (only usable with fieldtrip data currently; default = 'all')
%        pf_adjust: adjust frequency bands for theta, alpha, and beta (if
%        input) using the subjects individual alpha frequency (default =
%        'yes')
%        parameter: 'amplitude' or 'power' (default = 'power')



alltime_pre = cputime;

if strcmpi(settings.datatype,'EEG')
%    eeglab rebuild
%    addpath('/group/northoff/share/fieldtrip-master/external/eeglab')
end

settings = SetDefaults(settings);

cd(settings.inputdir)

if ~isempty(find(contains(settings.steps,'tf_filter')))
    disp('Performing time-frequency analysis...')
    tic;
    settings = NA_tf_func(settings);
    time_post = toc;
    disp(['Time-frequency analysis took ' num2str(time_post) ' seconds'])
end

cd(settings.outputdir)
% if ~isempty(find(contains(settings.steps,'calc')))
%     disp('Calculating TTV, ERSP, ITC...')
%     tic;
%     settings = TTV_ERSP_calc_func(settings);
%     time_post = toc;
%     disp(['Calculation of measures took ' num2str(time_post) ' seconds'])
% end

if ~isempty(find(contains(settings.steps,'results')))
    disp('Calculating indices and statistics...')
    tic;
    NA_results_func(settings)
    time_post = toc;
    disp(['Calculation took ' num2str(time_post) ' seconds'])
end

alltime_post = cputime;

disp('Analysis finished')
disp(['All steps took ' num2str(alltime_post-alltime_pre) ' seconds'])
disp(['Results saved in ' settings.outputdir])

end


function settings = SetDefaults(settings)

%settings = settings;

settings = setdefault(settings,'comparefreqs','no');

if ~isfield(settings,'files')
    if strmcpi(settings.datatype,'EEG')
        settings.files = '*.set';
    else
        settings.files = '*.mat';
    end
end

settings.tfparams = setdefault(settings.tfparams,'pf_adjust','no');

settings = setdefault(settings,'steps',{'all'});

if strcmpi(settings.steps{1},'all')
    settings.steps = {'tf_filter','results'};
end

settings = setdefault(settings,'srate',200);

settings = setdefault(settings,'units','prcchange');

settings.tfparams = setdefault(settings.tfparams,'trials','all');

settings.tfparams = setdefault(settings.tfparams,'method','hilbert');

settings.tfparams = setdefault(settings.tfparams,'continue','no');

settings.tfparams = setdefault(settings.tfparams,'parameter','power');

settings = setdefault(settings,'load_allmeas','no');

settings.nfreqs = length(settings.tfparams.fbandnames);

settings = setdefault(settings,'pool',8);

if length(settings.pool) == 1
    settings.pool = repmat(settings.pool,1,length(settings.steps)); % this way can set different pool sizes for different steps
end

if isfield(settings.datasetinfo,'label')
    settings.nbchan = length(settings.datasetinfo.label);
else
    settings.nbchan = length(settings.datasetinfo.atlas.tissuelabel);
end

end
