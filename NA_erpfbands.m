% script to make allmeas and alloutputs for ERP in different frequency
% bands

% First do the analyses
load('settings_camcan_1Hz_200msprestim.mat');

mainsettings = settings;

settings.steps = {'tf_filter','results'}; settings.pool = [48 48];
settings.tfparams.method = 'hilbert';
settings = rmfield('alpha_pf'); settings.load_allmeas = 'no';


bands = {[] [2 4] [4 8] [8 13] [13 30] [30 100] [100 200]};
fbandnames = {'Broadband','Delta','Theta','Alpha','Beta','Low Gamma','High Gamma'};

for i = 1:6
   settings.tfparams.fbands = bands([1 i+1]);
   settings.tfparams.fbandnames = fbandnames([1 i+1]);
   lprestim = floor(1000/(2*max(settings.tfparams.fbands{2}))); % half a cycle of the highest frequency in the band, in ms
   lprestim = floor(lprestim/2); % length in samples
   settings.pseudo.prestim = mainsettings.pseudo.prestim((end-(lprestim-1)):end);
   settings.real.prestim = mainsettings.real.prestim((end-(lprestim-1)):end);
   settings.datasetname = ['camcan_1Hz_erpfbands_' fbandnames{i+1}];
   NA_analysis(settings)
end


% Now combine the outputs structures into one larger structure
load('camcan_1Hz_revision_allmeas.mat');
mainmeas = allmeas;
load('camcan_1Hz_revision_results.mat');
mainoutputs = alloutputs;

files = dir('camcan_1Hz_erpfbands_*_allmeas.mat');

files = files([3 6 1 2 5 4]);

for i = 1:length(files)
    load(files(i).name)
    mainmeas{i+1} = allmeas{2};
    load(replace(files(i).name,'allmeas','results'));
    mainoutputs.erp.pt.stats{i+1} = alloutputs.erp.pt.stats{2};  
    mainoutputs.erp.pt.sig(i+1,:) = alloutputs.erp.pt.sig(2,:);
    mainoutputs.erp.ttv.stats{i+1} = alloutputs.erp.ttv.stats{2};
    mainoutputs.erp.ttv.sig(i+1,:) = alloutputs.erp.ttv.sig(2,:);
    mainoutputs.erp.corr.stats{i+1} = alloutputs.erp.corr.stats{2};
    mainoutputs.erp.corr.r(:,i+1) = alloutputs.erp.corr.r(:,2);
    mainoutputs.erp.corr.p(:,i+1) = alloutputs.erp.corr.p(:,2);
    mainoutputs.ersp.pt.stats{i+1} = alloutputs.erp.pt.stats{2};  
    mainoutputs.ersp.pt.sig(i+1,:) = alloutputs.erp.pt.sig(2,:);
    mainoutputs.ersp.ttv.stats{i+1} = alloutputs.erp.ttv.stats{2};
    mainoutputs.ersp.ttv.sig(i+1,:) = alloutputs.erp.ttv.sig(2,:);
    mainoutputs.ersp.corr.stats{i+1} = alloutputs.erp.corr.stats{2};
    mainoutputs.ersp.corr.r(:,i+1) = alloutputs.erp.corr.r(:,2);
    mainoutputs.ersp.corr.p(:,i+1) = alloutputs.erp.corr.p(:,2);
end

for i = 1:7
    mainmeas{i}.naddersp = mainmeas{i}.nadderp;
    mainmeas{i}.ttversp = mainmeas{i}.ttv;
end

mainoutputs.ersp.pt.stats(1) = mainoutputs.erp.pt.stats(1);
mainoutputs.ersp.ttv.stats(1) = mainoutputs.erp.ttv.stats(1);
mainoutputs.ersp.corr.r(:,1) = mainoutputs.erp.corr.r(:,1);
mainoutputs.ersp.corr.p(:,1) = mainoutputs.erp.corr.p(:,1);
mainoutputs.ersp.corr.stats(1) = mainoutputs.erp.corr.stats(1);


parsave('camcan_1Hz_erpfbands_windows_allmeas.mat','allmeas',mainmeas)
parsave('camcan_1Hz_erpfbands_windows_results.mat','alloutputs',mainoutputs)
