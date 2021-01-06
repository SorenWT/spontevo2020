% script for plotting the behaviour figure

for q = 1:2
    for i = 1:5
        for ii = 1:102
            behav_meas{q}.pvals{i}(ii) = behav_meas{q}.model{i}{ii}.Coefficients.pValue(2);
            behav_meas{q}.coeffs{i}(ii) = behav_meas{q}.model{i}{ii}.Coefficients.Estimate(2);
            behav_meas{q}.tstats{i}(ii) = behav_meas{q}.model{i}{ii}.Coefficients.tStat(2);
        end
        behav_meas{q}.p_fdr{i} = fdr(behav_meas{q}.pvals{i});
    end
end

figure
set(gcf,'color','w','units','normalized','position',[0 0 1 1])
p = panel('no-manage-font');
p.pack('v',{1/2 1/2})
p(1).pack('h',{20 20 20 20 20})
p(2).pack('h',{20 20 20 20 20})

for i = 1:5
    for q = 1:2
        p(q,i).select()
        ft_cluster_topoplot(settings.layout,behav_meas{q}.tstats{i},settings.datasetinfo.label,...
            behav_meas{q}.pvals{i},behav_meas{q}.p_fdr{i}<0.05);
        title(settings.tfparams.fbandnames{i+1},'FontSize',18)
    end
end
Normalize_Clim(gcf,1);
colormap(lkcmap2);

cbar = colorbar; cbar.FontSize = 18; cbar.Label.String = 't statistic';
p.de.margin = [5 5 5 5]; p(1).marginbottom = 24; p.margintop = 12;

savefig('camcan_1Hz_revision_behav_mixedeff.fig'); export_fig('camcan_1Hz_revision_behav_mixedeff.png','-m4')
