load('settings_camcan_1Hz.mat')

settings.pool = 48;

settings = NA_alpha_pf(settings);

cd(settings.inputdir)

files = dir(settings.files);

value = cell(length(files),102);
sig = cell(length(files),102);
z = cell(length(files),102);
parfor i = 1:length(files)
    data = parload(files(i).name,'data');
    datacat = cat(2,data.trial{:});
    for ii = 1:102
        [value{i,ii},z{i,ii},sig{i,ii}] = erpac_corr(datacat(ii,:),500,1001+1751*[0:(length(data.trial)-1)],[0 800],[],4,...
            settings.tfparams.fbands{i,4}(1),settings.tfparams.fbands{i,4}(2),200);
    end
end

pac.value = value; 
value = [];
pac.z = z; 
z = [];
pac.sig = sig; 
sig = [];

save([settings.datasetname '_erpac.mat'],'settings','pac','-v7.3')