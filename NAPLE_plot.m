% PLE Nonadditivity supplementary figure

cd ~/Documents/camcan/Preprocessed/Task/Epoched/IRASAtf

files = dir('*long.mat');

for i = 1:length(files)
   freqdata = parload([files(i).name '_IRASAtf.mat'],'frac');
   filename = files(i).name;
   Calc_naddPLE(settings,freqdata,filename);
end

cd ~/Documents/camcan/Nonadditivity
files = dir('*naddPLE.mat');

for i = 1:length(files)
    load(files(i).name);
    allnaple(i) = naple;
    allnaint(i) = naint;
end

allnaple = mergestructs(allnaple);
allnaint = mergestructs(allnaint);

opts.nrand = 1000; 
opts.parpool = 48;

naple_stats = EasyClusterCorrect({permute(squeeze(allnaple.diff(:,:,1,:)),[1 3 2]),permute(squeeze(allnaple.diff(:,:,2,:)),[1 3 2])},...
     settings.datasetinfo,'ft_statfun_fast_signrank',opts);
        
naint_stats = EasyClusterCorrect({permute(squeeze(allnaint.diff(:,:,1,:)),[1 3 2]),permute(squeeze(allnaint.diff(:,:,2,:)),[1 3 2])},...
     settings.datasetinfo,'ft_statfun_fast_signrank',opts);


 prestim_pseudo = settings.pseudo.prestim - settings.pseudo.prestim(1)+1+settings.srate/5;
 prestim_real = settings.real.prestim - settings.pseudo.prestim(1)+1+settings.srate/5;
 poststim_pseudo = settings.pseudo.poststim - settings.pseudo.prestim(1)+1+settings.srate/5;
 poststim_real = settings.real.poststim - settings.pseudo.prestim(1)+1+settings.srate/5;


figure

p = panel('no-manage-font');


set(gcf,'units','normalized','position',[0.2 0 0.6 1],'Color','w');

p.pack('v',{1/2 1/2})

toplot = {'allnaple','allnaint'};
statsforplot = {'naple_stats','naint_stats'};
labels = {'Fractal slope','Fractal intercept'};

for c = 1:2
    p(c).pack('h',{60 40});
    %for cc = 1:4
    %    p(c).pack({[0.25*(cc-1) 0 0.25 0.15]})
    %end
    p(c,2).pack(2,2)
    p(c,1).select();    
    
    dat = eval(toplot{c});
    stat = eval(statsforplot{c});
    
    t = linspace(0,length(settings.real.poststim)*(1/settings.srate),length(settings.real.poststim));
    hold on
    stdshade(t,squeeze(nanmean(dat.diff(:,:,1,:),1)),'b',0.15,1,'sem');
    
    stdshade(t,squeeze(nanmean(dat.diff(:,:,2,:),1)),'r',0.15,1,'sem');
    title(labels{c})
        legend({'Corrected prestim low','Corrected prestim high'})
    xlabel('Time (s)')
    ylabel('% change from prestim')
    
    FixAxes(gca,16)
    %set(gca,'FontSize',11,'TitleFontSizeMultiplier',1.1)
    
    plotindx = linspace(0,max(settings.aucindex),5);
    plotindx = movmean(plotindx,2);
    plotindx(1) = [];
    plotindx = round(plotindx);

    %tindx =
    for cc = 1:4
        p(c,2,ceil(cc/2),cc-2*floor(cc/3)).select()
        %axes(p(2,c,cc+1).axis)
        plotdata = nanmean(squeeze(dat.diff(:,plotindx(cc),2,:))...
            - squeeze(dat.diff(:,plotindx(cc),1,:)),2);
        if strcmpi(settings.datatype,'MEG')
            ft_cluster_topoplot(settings.layout,plotdata,settings.datasetinfo.label,...
                ones(size(stat.mask(:,plotindx(cc)))),stat.mask(:,plotindx(cc)));
        else
            cluster_topoplot(plotdata,settings.layout,...
                ones(size(stat.mask(:,plotindx(cc)))),stat.mask(:,plotindx(cc)));
        end
        colormap(lkcmap2)
        if cc == 4
            cbars(c) = colorbar;
        end
        ax(cc) = p(c,2,ceil(cc/2),cc-2*floor(cc/3)).axis;
        title([num2str(plotindx(cc)*(1000/settings.srate)) ' ms'],'FontSize',10)
        %Set_Clim(ax(cc),[prctile(plotdata,20) prctile(plotdata,80)]);
    end
    Normalize_Clim(ax,1);
    
end


p.de.margin = [5 5 5 5];
p.marginright = 20;
p.marginleft = 18;
p(1).marginbottom = 28;
p.marginbottom = 18;
p.margintop = 8;

% fix margins here

set(gcf,'Color','w')

for c = 1:2
    ax2(c) = p(c,1).axis;
    cbars(c).Position = [p(c,2).position(1)+p(c,2).position(3)+0.02*p(c,2).position(3) p(c,2).position(2)+0.25*p(c,2).position(4) ...
        cbars(c).Position(3) 0.5*p(c,2).position(4)];
end

    p(1,1).select()
    clust_sigmasks(gca,naple_stats);
    p(2,1).select()
    clust_sigmasks(gca,naint_stats);
    
    savefig('Fig_naddple.fig'); 
    export_fig('Fig_naddple.png','-m4');
    save('Panel_naddple.mat','p');
    %Plot_sigmask(p(2,c,1).axis,alloutputs.ersp.pt.stats{c}.prob < 0.05,'cmapline','LineWidth',5)
    %H = sigstar({get(p(c,1).axis,'XLim')},2*min(min(naple_stats.prob)),0,18)
    %delete(H(1)); pos = get(H(2),'position'); yl = get(gca,'YLim'); set(H(2),'position',[pos(1) yl(2)-0.05*diff(yl) pos(3)])