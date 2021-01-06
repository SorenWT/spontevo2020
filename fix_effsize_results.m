function results = fix_effsize_results(results)

ersp_pt_stats = results.ersp.pt.stats; 

for q = 1:length(ersp_pt_stats)
    if length(ersp_pt_stats{q}.posclusters) > 0
        ersp_pt_stats{q}.effsize_pos = sum(sum(ersp_pt_stats{q}.effsizetc.*(ersp_pt_stats{q}.posclusterslabelmat==1)))./...
            sum(sum(ersp_pt_stats{q}.posclusterslabelmat==1)); % mean effect size over all sensors in significant cluster
    end
    if length(ersp_pt_stats{q}.negclusters) > 0
        ersp_pt_stats{q}.effsize_neg = sum(sum(ersp_pt_stats{q}.effsizetc.*(ersp_pt_stats{q}.negclusterslabelmat==1)))./...
            sum(sum(ersp_pt_stats{q}.negclusterslabelmat==1)); % mean effect size over all sensors in significant cluster
    end
end
results.ersp.pt.stats = ersp_pt_stats;

ersp_ttv_stats = results.ersp.ttv.stats;
for q = 1:length(ersp_ttv_stats)
        if length(ersp_ttv_stats{q}.posclusters)>0
            ersp_ttv_stats{q}.effsize_pos = sum(sum(ersp_ttv_stats{q}.effsizetc.*(ersp_ttv_stats{q}.posclusterslabelmat==1)))./...
                sum(sum(ersp_ttv_stats{q}.posclusterslabelmat==1)); % mean effect size over all sensors in significant cluster
        end
        if length(ersp_ttv_stats{q}.negclusters)>0
            ersp_ttv_stats{q}.effsize_neg = sum(sum(ersp_ttv_stats{q}.effsizetc.*(ersp_ttv_stats{q}.negclusterslabelmat==1)))./...
                sum(sum(ersp_ttv_stats{q}.negclusterslabelmat==1)); % mean effect size over all sensors in significant cluster
        end
end
results.ersp.ttv.stats = ersp_ttv_stats;

erp_pt_stats = results.erp.pt.stats; 

for q = 1:length(erp_pt_stats)
    if length(erp_pt_stats{q}.posclusters) > 0
        erp_pt_stats{q}.effsize_pos = sum(sum(erp_pt_stats{q}.effsizetc.*(erp_pt_stats{q}.posclusterslabelmat==1)))./...
            sum(sum(erp_pt_stats{q}.posclusterslabelmat==1)); % mean effect size over all sensors in significant cluster
    end
    if length(erp_pt_stats{q}.negclusters) > 0
        erp_pt_stats{q}.effsize_neg = sum(sum(erp_pt_stats{q}.effsizetc.*(erp_pt_stats{q}.negclusterslabelmat==1)))./...
            sum(sum(erp_pt_stats{q}.negclusterslabelmat==1)); % mean effect size over all sensors in significant cluster
    end
end
results.erp.pt.stats = erp_pt_stats;

erp_ttv_stats = results.erp.ttv.stats;
for q = 1:length(erp_ttv_stats)
        if length(erp_ttv_stats{q}.posclusters)>0
            erp_ttv_stats{q}.effsize_pos = sum(sum(erp_ttv_stats{q}.effsizetc.*(erp_ttv_stats{q}.posclusterslabelmat==1)))./...
                sum(sum(erp_ttv_stats{q}.posclusterslabelmat==1)); % mean effect size over all sensors in significant cluster
        end
        if length(erp_ttv_stats{q}.negclusters)>0
            erp_ttv_stats{q}.effsize_neg = sum(sum(erp_ttv_stats{q}.effsizetc.*(erp_ttv_stats{q}.negclusterslabelmat==1)))./...
                sum(sum(erp_ttv_stats{q}.negclusterslabelmat==1)); % mean effect size over all sensors in significant cluster
        end
end
results.erp.ttv.stats = erp_ttv_stats;