% script to make allmeas and alloutputs for ERP stuff

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
