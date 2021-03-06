function NA_results_func(settings)

numbands = length(settings.tfparams.fbandnames);

alloutputs = struct;

if strcmpi(settings.tfparams.method,'hilbert')
    nerp = numbands;
else
    nerp = 1;
end

if strcmpi(settings.tfparams.pf_adjust,'yes') && size(settings.tfparams.fbands,1) == 1
    settings = NA_alpha_pf(settings);
    %  alloutputs.alpha_pf = settings.alpha_pf;
    %  alloutputs.fbands_adjusted = settings.tfparams.fbands;
end
%alloutputs.settings = settings;

save(fullfile(settings.outputdir,[settings.datasetname '_results.mat']),'alloutputs','-v7.3')

% Construct allmeas
if ~exist(fullfile(settings.outputdir,[settings.datasetname '_allmeas.mat']),'file') || strcmpi(settings.load_allmeas,'no')
    files = dir([settings.datasetname '*calc.mat']);
    
    datacalc = parload(files(1).name,'datacalc');
    fields = cell_unpack(fieldnames_recurse(datacalc{1}));
    
    alldata = cell(1,length(files));
    
    parfor c = 1:length(files)
        fprintf([num2str(c) ' '])
        datacalc = parload(files(c).name,'datacalc')
        dimn = [];
        for q = 1:length(datacalc)
            fields = fieldnames_recurse(datacalc{q});
            fields = cell_unpack(fields);
            for cc = 1:length(fields)
                alldata{c}{q,cc} = getfield_nest(datacalc{q},fields{cc});
                %allmeas{q} = assignfield_nest(allmeas{q},fields{cc},tmp);
            end
        end
    end
    
    alldata = cat(3,alldata{:});
    
    datacalc = parload(files(1).name,'datacalc');
    allmeas = datacalc;
    
    for c = 1:length(files)
        allmeas{1}.filesorder{c} = files(c).name;
    end
    
    for q = 1:length(allmeas)
        fields = cell_unpack(fieldnames_recurse(datacalc{q}));
        for c = 1:length(fields)
            dimn = size(getfield_nest(datacalc{q},fields{c}));
            %dimn = length(find(size > 1));
            if dimn(end) == 1
                dimn(end) = [];
            end
            dimn = length(dimn);
            if(~strcmpi(fields{c},'ersp.poststimindx') && ~strcmpi(fields{c},'ersp.prestimpow'))
                tmp = cat(dimn+1,alldata{q,c,:});
            else
                tmp = squeeze(alldata(q,c,:));
            end
            allmeas{q} = assignfield_nest(allmeas{q},fields{c},tmp);
        end
    end
    
    save(fullfile(settings.outputdir,[settings.datasetname '_allmeas.mat']),'allmeas','-v7.3')
elseif strcmpi(settings.load_allmeas,'yes')
    load(fullfile(settings.outputdir,[settings.datasetname '_allmeas.mat']))
end

aucindex = settings.aucindex;

nbchan = settings.nbchan;

%% Comparison of TTV and ERSP time course in each frequency band

for q = 1:numbands
    for c = 1:nbchan
        for i = 1:size(allmeas{q}.ttv.real,3)
            alloutputs.ersp.distrealreal(c,i,q) = norm(NormOntoRange(allmeas{q}.ttv.real(c,:,i),[0 1])-NormOntoRange(allmeas{q}.ersp.real(c,:,i),[0 1]));
            alloutputs.ersp.distrealpseudo(c,i,q) = norm(NormOntoRange(allmeas{q}.ttv.real(c,:,i),[0 1])-NormOntoRange(allmeas{q}.ersp.pseudo(c,:,i),[0 1]));
            alloutputs.ersp.distpseudoreal(c,i,q) = norm(NormOntoRange(allmeas{q}.ttv.pseudo(c,:,i),[0 1])-NormOntoRange(allmeas{q}.ersp.real(c,:,i),[0 1]));
            alloutputs.ersp.distpseudopseudo(c,i,q) = norm(NormOntoRange(allmeas{q}.ttv.pseudo(c,:,i),[0 1])-NormOntoRange(allmeas{q}.ersp.pseudo(c,:,i),[0 1]));
            
            alloutputs.itc.distrealreal(c,i,q) = norm(NormOntoRange(allmeas{q}.ttv.real(c,:,i),[0 1])-(1-NormOntoRange(allmeas{q}.itc.real(c,:,i),[0 1])));
            alloutputs.itc.distrealpseudo(c,i,q) = norm(NormOntoRange(allmeas{q}.ttv.real(c,:,i),[0 1])-(1-NormOntoRange(allmeas{q}.itc.pseudo(c,:,i),[0 1])));
            alloutputs.itc.distpseudoreal(c,i,q) = norm(NormOntoRange(allmeas{q}.ttv.pseudo(c,:,i),[0 1])-(1-NormOntoRange(allmeas{q}.itc.real(c,:,i),[0 1])));
            alloutputs.itc.distpseudopseudo(c,i,q) = norm(NormOntoRange(allmeas{q}.ttv.pseudo(c,:,i),[0 1])-(1-NormOntoRange(allmeas{q}.itc.pseudo(c,:,i),[0 1])));
        end
    end
    alloutputs.dist.sigersp(q,:) = signrank_mat(alloutputs.ersp.distrealreal(:,:,q),alloutputs.ersp.distrealpseudo(:,:,q),2);
    alloutputs.dist.sigitc(q,:) = signrank_mat(alloutputs.itc.distrealreal(:,:,q),alloutputs.itc.distrealpseudo(:,:,q),2);
    alloutputs.dist.sigerspvitc(q,:) = signrank_mat(alloutputs.ersp.distrealreal(:,:,q),alloutputs.itc.distrealreal(:,:,q),2);
end

%% Cluster stats

if ~strcmpi(settings.datatype,'ECoG') || strcmpi(settings.ecog.method,'roi')
    
    ttv_diststats = cell(1,numbands);
    
    ersp_pt_stats = cell(1,numbands);
    ersp_ttv_stats = cell(1,numbands);
    ersp_corrstats = cell(1,numbands);
    
    erp_pt_stats = cell(1,nerp);
    erp_corrstats = cell(1,nerp);
    erp_ttv_stats = cell(1,nerp);
    
    opts = struct;
    opts.nrand = 10000;
    
    if strcmpi(settings.datatype,'ECoG')
        opts.minnbchan = 0;
    end
    
    opts.parpool = settings.pool(find(strcmpi(settings.steps,'results')));
    
    tcourse_design = tril(ones(numbands))-eye(numbands);
    
    ersp_pt_tcoursestats = cell(numbands);
    ersp_ttv_tcoursestats = cell(numbands);
    
    for q = 1:numbands
        disp(['Processing ' settings.tfparams.fbandnames{q} ' band'])
        
        zeromat = zeros(size(allmeas{q}.ttv.real));
        zeromat(find(isnan(allmeas{q}.ttv.real))) = NaN;
        
        %        ttv_diststats{q} = EasyClusterCorrect({alloutputs.itc.distrealreal(:,:,q),alloutputs.ersp.distrealreal(:,:,q)},settings.datasetinfo,'ft_statfun_fast_signrank',opts);
        
        ersp_pt_stats{q} = EasyClusterCorrect({permute(squeeze(allmeas{q}.naddersp.diff(:,:,1,:)),[1 3 2]),permute(squeeze(allmeas{q}.naddersp.diff(:,:,2,:)),[1 3 2])},...
            settings.datasetinfo,'ft_statfun_fast_signrank',opts);
        ersp_pt_stats{q}.effsizetc = squeeze(mean(permute(squeeze(allmeas{q}.naddersp.diff(:,:,1,:)),[1 3 2])-permute(squeeze(allmeas{q}.naddersp.diff(:,:,2,:)),[1 3 2]),2)./...
            std(permute(squeeze(allmeas{q}.naddersp.diff(:,:,1,:)),[1 3 2])-permute(squeeze(allmeas{q}.naddersp.diff(:,:,2,:)),[1 3 2]),[],2));
        if length(ersp_pt_stats{q}.posclusters) > 0
            ersp_pt_stats{q}.effsize_pos = sum(sum(ersp_pt_stats{q}.effsizetc.*(ersp_pt_stats{q}.posclusterslabelmat==1)))./...
                sum(sum(ersp_pt_stats{q}.posclusterslabelmat==1)); % mean effect size over all sensors in significant cluster
        end
        if length(ersp_pt_stats{q}.negclusters) > 0
            ersp_pt_stats{q}.effsize_neg = sum(sum(ersp_pt_stats{q}.effsizetc.*(ersp_pt_stats{q}.negclusterslabelmat==1)))./...
                sum(sum(ersp_pt_stats{q}.negclusterslabelmat==1)); % mean effect size over all sensors in significant cluster
        end
        
        ersp_ttv_stats{q} = EasyClusterCorrect({permute(allmeas{q}.ttversp.real,[1 3 2]) permute(zeromat,[1 3 2])},settings.datasetinfo,'ft_statfun_fast_signrank',opts);
        ersp_ttv_stats{q}.effsizetc = squeeze(mean(permute(allmeas{q}.ttversp.real,[1 3 2]),2)./...
            std(permute(allmeas{q}.ttversp.real,[1 3 2]),[],2));
        if length(ersp_ttv_stats{q}.posclusters)>0
            ersp_ttv_stats{q}.effsize_pos = sum(sum(ersp_ttv_stats{q}.effsizetc.*(ersp_ttv_stats{q}.posclusterslabelmat==1)))./...
                sum(sum(ersp_ttv_stats{q}.posclusterslabelmat==1)); % mean effect size over all sensors in significant cluster
        end
        if length(ersp_ttv_stats{q}.negclusters)>0
            ersp_ttv_stats{q}.effsize_neg = sum(sum(ersp_ttv_stats{q}.effsizetc.*(ersp_ttv_stats{q}.negclusterslabelmat==1)))./...
                sum(sum(ersp_ttv_stats{q}.negclusterslabelmat==1)); % mean effect size over all sensors in significant cluster
        end
        
        ersp_corrstats{q} = EasyClusterCorrect({allmeas{q}.naerspindex,allmeas{q}.ttverspindex},settings.datasetinfo,'ft_statfun_correlationT',opts);
        try
            if q <= nerp
                erp_pt_stats{q} = EasyClusterCorrect({permute(squeeze(allmeas{q}.nadderp.diff(:,:,1,:)),[1 3 2]),permute(squeeze(allmeas{q}.nadderp.diff(:,:,2,:)),[1 3 2])},...
                    settings.datasetinfo,'ft_statfun_fast_signrank',opts);
                erp_pt_stats{q}.effsizetc = squeeze(mean(permute(squeeze(allmeas{q}.nadderp.diff(:,:,1,:)),[1 3 2])-permute(squeeze(allmeas{q}.nadderp.diff(:,:,2,:)),[1 3 2]),2)./...
                    std(permute(squeeze(allmeas{q}.nadderp.diff(:,:,1,:)),[1 3 2])-permute(squeeze(allmeas{q}.nadderp.diff(:,:,2,:)),[1 3 2]),[],2));
                
                if length(erp_pt_stats{q}.posclusters)>0
                    erp_pt_stats{q}.effsize_pos = sum(sum(erp_pt_stats{q}.effsizetc.*(erp_pt_stats{q}.posclusterslabelmat==1)))./sum(sum(erp_pt_stats{q}.posclusterslabelmat==1)); % mean effect size over all sensors in significant cluster
                end
                if length(erp_pt_stats{q}.negclusters)>0
                    erp_pt_stats{q}.effsize_neg = sum(sum(erp_pt_stats{q}.effsizetc.*(erp_pt_stats{q}.negclusterslabelmat==1)))./sum(sum(erp_pt_stats{q}.negclusterslabelmat==1)); % mean effect size over all sensors in significant cluster
                end
                
                erp_ttv_stats{q} = EasyClusterCorrect({permute(allmeas{q}.ttv.real,[1 3 2]) permute(zeromat,[1 3 2])},settings.datasetinfo,'ft_statfun_fast_signrank',opts);
                erp_ttv_stats{q}.effsizetc = squeeze(mean(permute(allmeas{q}.ttv.real,[1 3 2]),2)./...
                    std(permute(allmeas{q}.ttv.real,[1 3 2]),[],2));
                if length(erp_ttv_stats{q}.posclusters)>0
                    erp_ttv_stats{q}.effsize_pos = sum(sum(erp_ttv_stats{q}.effsizetc.*(erp_ttv_stats{q}.posclusterslabelmat==1)))./...
                        sum(sum(erp_ttv_stats{q}.posclusterslabelmat==1)); % mean effect size over all sensors in significant cluster
                end
                if length(erp_ttv_stats{q}.negclusters)>0
                    erp_ttv_stats{q}.effsize_neg = sum(sum(erp_ttv_stats{q}.effsizetc.*(erp_ttv_stats{q}.negclusterslabelmat==1)))./...
                        sum(sum(erp_ttv_stats{q}.negclusterslabelmat==1)); % mean effect size over all sensors in significant cluster
                end
                
                erp_corrstats{q} = EasyClusterCorrect({allmeas{q}.naerpindex,allmeas{q}.ttvindex},settings.datasetinfo,'ft_statfun_correlationT',opts);
            end
        catch
        end
        
        if strcmpi(settings.comparefreqs,'yes')
            for c = (q+1):numbands
                ersp_pt_tcoursestats{q,c} = EasyClusterCorrect({permute(squeeze(allmeas{q}.naddersp.diff(:,:,2,:)-allmeas{q}.naddersp.diff(:,:,1,:)),[1 3 2]),...
                    permute(squeeze(allmeas{c}.naddersp.diff(:,:,2,:)-allmeas{c}.naddersp.diff(:,:,1,:)),[1 3 2])},...
                    settings.datasetinfo,'ft_statfun_fast_signrank',opts);
                ttv_pt_tcoursestats{q,c} = EasyClusterCorrect({permute(allmeas{q}.ttversp.real,[1 3 2]),permute(allmeas{c}.ttversp.real,[1 3 2])},...
                    settings.datasetinfo,'ft_statfun_fast_signrank',opts);
            end
        end
    end
    
    
    alloutputs.dist.stats = ttv_diststats;
    alloutputs.ersp.pt.stats = ersp_pt_stats;
    alloutputs.ersp.pt.tcoursestats = ersp_pt_tcoursestats;
    alloutputs.ersp.ttv.tcoursestats = ersp_ttv_tcoursestats;
    alloutputs.ersp.ttv.stats = ersp_ttv_stats;
    alloutputs.erp.pt.stats = erp_pt_stats;
    alloutputs.erp.ttv.stats = erp_ttv_stats;
    
    alloutputs.fdrfields = {'ersp.pt.stats','ersp.ttv.stats','ersp.corr.stats',...
        'erp.pt.stats','erp.ttv.stats','erp.corr.stats'};
elseif strcmpi(settings.datatype,'ECoG') && (strcmpi(settings.ecog.method,'mean') || strcmpi(settings.ecog.method,'median'))
    alloutputs.fdrfields = {'ersp.pt.sig','ersp.ttv.sig','ersp.corr.p','erp.pt.sig','erp.ttv.sig',...
        'erp.corr.p'};
end

% Save these results since they take so long to calculate
save([settings.outputdir '/' settings.datasetname '_results.mat'],'alloutputs','-v7.3')

%% Recalculate NA indices based on cluster inclusion and do correlations for cluster stats

for q = 1:numbands
    tmp = allmeas{q}.naddersp.diff.*alloutputs.ersp.pt.stats{q}.mask;
    allmeas{q}.naerspindex = squeeze(trapz(tmp(:,:,2,:),2)-trapz(tmp(:,:,1,:),2));
    if q <= nerp
        try
            tmp = allmeas{q}.nadderp.diff.*alloutputs.erp.pt.stats{q}.mask;
            allmeas{q}.naerpindex = squeeze(trapz(tmp(:,:,2,:),2)-trapz(tmp(:,:,1,:),2));
            tmp = allmeas{q}.ttv.real.*alloutputs.erp.ttv.stats{q}.mask;
            allmeas{q}.ttvindex = squeeze(trapz(tmp,2));
        catch
        end
    end
    tmp = allmeas{q}.ttversp.real.*alloutputs.ersp.ttv.stats{q}.mask;
    allmeas{q}.ttverspindex = squeeze(trapz(tmp,2));
end

for q = 1:numbands
    try
        ersp_corrstats{q} = EasyClusterCorrect({allmeas{q}.naerspindex,allmeas{q}.ttverspindex},settings.datasetinfo,'ft_statfun_spearman',opts);
        if q <= nerp
            erp_corrstats{q} = EasyClusterCorrect({allmeas{q}.naerpindex,allmeas{q}.ttvindex},settings.datasetinfo,'ft_statfun_spearman',opts);
        end
    catch
    end
end

alloutputs.ersp.corr.stats = ersp_corrstats;
alloutputs.erp.corr.stats = erp_corrstats;


%% Calculation of nonadditivity significance in ERSP

for q = 1:numbands
    alloutputs.ersp.pt.sig(q,:) = signrank_mat(allmeas{q}.naerspindex,zeros(size(allmeas{q}.naerspindex)),2);
    alloutputs.ersp.ttv.sig(q,:) = signrank_mat(allmeas{q}.ttverspindex,zeros(size(allmeas{q}.ttverspindex)),2);
    [r p] = nancorr(allmeas{q}.naerspindex',allmeas{q}.ttverspindex','Type','Spearman');
    alloutputs.ersp.corr.r(:,q) = r(find(eye(nbchan)));
    alloutputs.ersp.corr.p(:,q) = p(find(eye(nbchan)));
end

%% Calculation of ERP nonadditivity
try
    for q = 1:nerp
        alloutputs.erp.pt.sig(q,:) = signrank_mat(allmeas{q}.naerpindex,zeros(size(allmeas{q}.naerpindex)),2);
        alloutputs.erp.ttv.sig(q,:) = signrank_mat(allmeas{q}.ttvindex,zeros(size(allmeas{q}.ttvindex)),2);
        [r p] = nancorr(allmeas{q}.naerpindex',allmeas{q}.ttvindex','Type','Spearman');
        alloutputs.erp.corr.r(:,q) = r(find(eye(nbchan)));
        alloutputs.erp.corr.p(:,q) = p(find(eye(nbchan)));
    end
catch
end

alloutputs.filesorder = allmeas{1}.filesorder;

save(fullfile(settings.outputdir,[settings.datasetname '_allmeas.mat']),'allmeas','-v7.3')
save(fullfile(settings.outputdir,[settings.datasetname '_results.mat']),'alloutputs','-v7.3')

end
