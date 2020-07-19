% correlating PAC and ITC results with NA

load('camcan_1Hz_newavg_results.mat')
load('camcan_1Hz_newavg_allmeas.mat')
load('settings_camcan_1Hz.mat')

opts.nrand = 1000; opts.parpool = 48;

pacstats = EasyClusterCorrect({permute(pac.z,[2 1 3]) zeros(102,474,401)},settings.datasetinfo,'ft_statfun_fast_signrank',opts);


diffdiff = allmeas{4}.naddersp.diff(:,:,2,:)-allmeas{4}.naddersp.diff(:,:,1,:);
diffdiff = squeeze(diffdiff);

z = pac.z(:,:,1:400);
for i = 1:102
    for ii = 1:400
        [corrrho_pac(i,ii),corrp_pac(i,ii)] = corr(squeeze(diffdiff(i,ii,:)),z(:,i,ii),'type','spearman');
    end
end

prestim_pseudo = settings.pseudo.prestim - settings.pseudo.prestim(1)+1+settings.srate/5;
prestim_real = settings.real.prestim - settings.pseudo.prestim(1)+1+settings.srate/5;
poststim_pseudo = settings.pseudo.poststim - settings.pseudo.prestim(1)+1+settings.srate/5;
poststim_real = settings.real.poststim - settings.pseudo.prestim(1)+1+settings.srate/5;

itc = allmeas{2}.raw.itc(:,poststim_real,:);

for i = 1:102
    for ii = 1:400
        [corrrho_itc(i,ii),corrp_itc(i,ii)] = corr(squeeze(diffdiff(i,ii,:)),squeeze(itc(i,ii,:)),'type','spearman');
    end
end

for i = 1:102
    for ii = 1:400
        [corrrho_rxn(i,ii),corrp_rxn(i,ii)] = corr(squeeze(diffdiff(i,ii,:)).*squeeze(itc(i,ii,:)),z(:,i,ii),'type','spearman');
    end
end

corrstats_pac = EasyClusterCorrect({permute(z,[2 1 3]),permute(diffdiff,[1 3 2])},settings.datasetinfo,'ft_statfun_spearman',opts);
corrstats_itc = EasyClusterCorrect({permute(allmeas{2}.raw.itc(:,poststim_real,:),[1 3 2]),permute(diffdiff,[1 3 2])},settings.datasetinfo,'ft_statfun_spearman',opts);
corrstats_rxn = EasyClusterCorrect({permute(z,[2 1 3]),permute(diffdiff,[1 3 2]).*permute(itc,[1 3 2])},settings.datasetinfo,'ft_statfun_spearman',opts);

t = linspace(0,800,401);
pacindx = squeeze(trapz(t,permute(pac.z,[2 3 1]).*pacstats.mask,2));

corrstats_indx_pac = EasyClusterCorrect({pacindx,allmeas{4}.naerspindex},settings.datasetinfo,'ft_statfun_spearman',opts);
corrstats_indx_itc = EasyClusterCorrect({allmeas{2}.itcindex,allmeas{4}.naerspindex},settings.datasetinfo,'ft_statfun_spearman',opts);
corrstats_indx_rxn = EasyClusterCorrect({pacindx.*allmeas{2}.itcindex,allmeas{4}.naerspindex},settings.datasetinfo,'ft_statfun_spearman',opts);


t = t(1:400);

c=4;


figure

p = panel('no-manage-font');
set(gcf,'units','normalized','position',[0 0 1 1])

p.pack('h',{1/4 1/4 1/4 1/4})
p(1).pack('v',{1/2 1/2})
p(2).pack('v',{1/2 1/2})
p(3).pack('v',{1/2 1/2})
p(4).pack('v',{1/2 1/2})


p(1,1).pack()
for cc = 1:4
    p(1,1).pack({[0.25*(cc-1) 0 0.25 0.15]})
end

p(1,1,1).select()
plot(t,squeeze(mean(mean(pac.value(:,:,1:400),1),2)),'LineWidth',2)
xlabel('Time (ms)')
ylabel('Circular-linear correlation')
FixAxes(gca,14)
H = sigstar({[0 800]},0.002,0,18);
delete(H(1));



plotindx = linspace(0,max(settings.aucindex),5);
plotindx = movmean(plotindx,2);
plotindx = round(plotindx);
plotindx(1) = [];

for cc = 1:4
    p(1,1,cc+1).select()
    plotdata = mean(pac.value(:,:,plotindx(cc)),2);
    if strcmpi(settings.datatype,'MEG')
        ft_cluster_topoplot(settings.layout,plotdata,settings.datasetinfo.label,...
            ones(size(alloutputs.ersp.ttv.stats{4}.mask(:,plotindx(cc)))),0.*alloutputs.ersp.ttv.stats{c}.mask(:,plotindx(cc)));
    else
        cluster_topoplot(plotdata,settings.layout,...
            1-(0.*alloutputs.ersp.ttv.stats{4}.mask(:,plotindx(cc))),0.*alloutputs.ersp.ttv.stats{c}.mask(:,plotindx(cc)));
    end
    colormap(lkcmap2)
    if cc == 4
        cbars1 = colorbar;
    end
    ax(cc) = p(1,1,cc+1).axis;
    title([num2str(plotindx(cc)*(1000/settings.srate)) ' ms'],'FontSize',10)
   % Set_Clim(ax(cc),[prctile(plotdata,20) prctile(plotdata,80)]);
end
Normalize_Clim(ax,1);

p(1,2).pack()
for cc = 1:4
    p(1,2).pack({[0.25*(cc-1) 0 0.25 0.15]})
end

p(1,2,1).select()
plot(t,mean(mean(allmeas{2}.itc.real,1),3),'LineWidth',2)
xlabel('Time (ms)')
ylabel('% change in ITC')
FixAxes(gca,14)
H = sigstar({[0 800]},0.002,0,18);
delete(H(1));

plotindx = linspace(0,max(settings.aucindex),5);
plotindx = movmean(plotindx,2);
plotindx = round(plotindx);
plotindx(1) = [];

for cc = 1:4
    p(1,2,cc+1).select()
    plotdata = mean(allmeas{2}.itc.real(:,plotindx(cc),:),3);
    if strcmpi(settings.datatype,'MEG')
        ft_cluster_topoplot(settings.layout,plotdata,settings.datasetinfo.label,...
            ones(size(alloutputs.ersp.ttv.stats{c}.mask(:,plotindx(cc)))),0.*alloutputs.ersp.ttv.stats{c}.mask(:,plotindx(cc)));
    else
        cluster_topoplot(plotdata,settings.layout,...
            1-(0.*alloutputs.ersp.ttv.stats{c}.mask(:,plotindx(cc))),0.*alloutputs.ersp.ttv.stats{c}.mask(:,plotindx(cc)));
    end
    colormap(lkcmap2)
    if cc == 4
        cbars1(c) = colorbar;
    end
    ax(cc) = p(1,2,cc+1).axis;
    title([num2str(plotindx(cc)*(1000/settings.srate)) ' ms'],'FontSize',10)
   % Set_Clim(ax(cc),[prctile(plotdata,20) prctile(plotdata,80)]);
end
Normalize_Clim(ax,1);


p(2,1).pack()
for cc = 1:4
    p(2,1).pack({[0.25*(cc-1) 0 0.25 0.15]})
end

p(2,1,1).select()
plot(t,mean(corrrho_pac,1),'LineWidth',2)
xlabel('Time (ms)')
ylabel('Spearman''s \rho')
title('Correlation with Phase-Amplitude Coupling')

plotindx = linspace(0,max(settings.aucindex),5);
plotindx = movmean(plotindx,2);
plotindx = round(plotindx);
plotindx(1) = [];

for cc = 1:4
    p(2,1,cc+1).select()
    plotdata = corrrho_pac(:,plotindx(cc));
    if strcmpi(settings.datatype,'MEG')
        ft_cluster_topoplot(settings.layout,plotdata,settings.datasetinfo.label,...
            ones(size(alloutputs.ersp.ttv.stats{c}.mask(:,plotindx(cc)))),0.*alloutputs.ersp.ttv.stats{c}.mask(:,plotindx(cc)));
    else
        cluster_topoplot(plotdata,settings.layout,...
            1-(0.*alloutputs.ersp.ttv.stats{c}.mask(:,plotindx(cc))),0.*alloutputs.ersp.ttv.stats{c}.mask(:,plotindx(cc)));
    end
    colormap(lkcmap2)
    if cc == 4
        cbars1(c) = colorbar;
    end
    ax(cc) = p(2,1,cc+1).axis;
    title([num2str(plotindx(cc)*(1000/settings.srate)) ' ms'],'FontSize',10)
   % Set_Clim(ax(cc),[prctile(plotdata,20) prctile(plotdata,80)]);
end
Normalize_Clim(ax,1);

p(2,2).pack()
p(2,2).pack({[0.7 0 0.3 0.3]})

p(2,2,1).select()
nicecorrplot(nanmean(pacindx,1),nanmean(allmeas{4}.naerspindex,1),...
    {'Phase-amplitude coupling index',['Pseudotrial-based' newline 'ERSP nonadditivity index']},'Plot','r');
FixAxes(gca,14)

p(2,2,2).select()
[rvals,pvals] = corr(pacindx',allmeas{4}.naerspindex','type','spearman');
rvals = diag(rvals); pvals = diag(pvals);
ft_cluster_topoplot(settings.layout,rvals,settings.datasetinfo.label,...
     pvals,corrstats_indx_pac.mask);

colormap(lkcmap2)
cbars2 = colorbar('EastOutside');
FixAxes(gca,14)


p(3,1).pack()
for cc = 1:4
    p(3,1).pack({[0.25*(cc-1) 0 0.25 0.15]})
end

p(3,1,1).select()
plot(t,mean(corrrho_itc,1),'LineWidth',2)
xlabel('Time (ms)')
ylabel('Spearman''s \rho')
title('Correlation with Inter-Trial Coherence')

plotindx = linspace(0,max(settings.aucindex),5);
plotindx = movmean(plotindx,2);
plotindx = round(plotindx);
plotindx(1) = [];

for cc = 1:4
    p(3,1,cc+1).select()
    plotdata = corrrho_itc(:,plotindx(cc));
    if strcmpi(settings.datatype,'MEG')
        ft_cluster_topoplot(settings.layout,plotdata,settings.datasetinfo.label,...
            ones(size(alloutputs.ersp.ttv.stats{c}.mask(:,plotindx(cc)))),0.*alloutputs.ersp.ttv.stats{c}.mask(:,plotindx(cc)));
    else
        cluster_topoplot(plotdata,settings.layout,...
            1-(0.*alloutputs.ersp.ttv.stats{c}.mask(:,plotindx(cc))),0.*alloutputs.ersp.ttv.stats{c}.mask(:,plotindx(cc)));
    end
    colormap(lkcmap2)
    if cc == 4
        cbars1(c) = colorbar;
    end
    ax(cc) = p(3,1,cc+1).axis;
    title([num2str(plotindx(cc)*(1000/settings.srate)) ' ms'],'FontSize',10)
   % Set_Clim(ax(cc),[prctile(plotdata,20) prctile(plotdata,80)]);
end
Normalize_Clim(ax,1);

p(3,2).pack()
p(3,2).pack({[0.7 0 0.3 0.3]})

p(3,2,1).select()
nicecorrplot(nanmean(allmeas{2}.itcindex,1),nanmean(allmeas{4}.naerspindex,1),...
    {'Inter-trial coherence index',['Pseudotrial-based' newline 'ERSP nonadditivity index']},'Plot','r');
FixAxes(gca,14)

p(3,2,2).select()
[rvals,pvals] = corr(allmeas{2}.itcindex',allmeas{4}.naerspindex','type','spearman');
rvals = diag(rvals); pvals = diag(pvals);
ft_cluster_topoplot(settings.layout,rvals,settings.datasetinfo.label,...
     pvals,corrstats_indx_itc.mask);

colormap(lkcmap2)
cbars2 = colorbar('EastOutside');
FixAxes(gca,14)

p(4,1).pack()
for cc = 1:4
    p(4,1).pack({[0.25*(cc-1) 0 0.25 0.15]})
end

p(4,1,1).select()
plot(t,mean(corrrho_rxn,1),'LineWidth',2)
xlabel('Time (ms)')
ylabel('Spearman''s \rho')
title('Correlation with ITC*PAC interaction')

plotindx = linspace(0,max(settings.aucindex),5);
plotindx = movmean(plotindx,2);
plotindx = round(plotindx);
plotindx(1) = [];

for cc = 1:4
    p(4,1,cc+1).select()
    plotdata = corrrho_rxn(:,plotindx(cc));
    if strcmpi(settings.datatype,'MEG')
        ft_cluster_topoplot(settings.layout,plotdata,settings.datasetinfo.label,...
            ones(size(alloutputs.ersp.ttv.stats{c}.mask(:,plotindx(cc)))),0.*alloutputs.ersp.ttv.stats{c}.mask(:,plotindx(cc)));
    else
        cluster_topoplot(plotdata,settings.layout,...
            1-(0.*alloutputs.ersp.ttv.stats{c}.mask(:,plotindx(cc))),0.*alloutputs.ersp.ttv.stats{c}.mask(:,plotindx(cc)));
    end
    colormap(lkcmap2)
    if cc == 4
        cbars1(c) = colorbar;
    end
    ax(cc) = p(4,1,cc+1).axis;
    title([num2str(plotindx(cc)*(1000/settings.srate)) ' ms'],'FontSize',10)
   % Set_Clim(ax(cc),[prctile(plotdata,20) prctile(plotdata,80)]);
end
Normalize_Clim(ax,1);

p(4,2).pack()
p(4,2).pack({[0.7 0 0.3 0.3]})

p(4,2,1).select()
nicecorrplot(nanmean(pacindx,1),nanmean(allmeas{4}.naerspindex,1),...
    {'Phase-amplitude coupling index',['Pseudotrial-based' newline 'ERSP nonadditivity index']},'Plot','r');
FixAxes(gca,14)

p(4,2,2).select()
[rvals,pvals] = corr(pacindx'.*allmeas{2}.itcindex',allmeas{4}.naerspindex','type','spearman');
rvals = diag(rvals); pvals = diag(pvals);
ft_cluster_topoplot(settings.layout,real(rvals),settings.datasetinfo.label,...
     pvals,corrstats_indx_rxn.mask);

colormap(lkcmap2)
cbars2 = colorbar('EastOutside');
FixAxes(gca,14)

p.de.marginleft = 35;
p.margintop = 10; 
p.marginright = 8; 
p(1,1).marginbottom = 25;



