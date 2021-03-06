function ft_cluster_topoplot(layout,vect,label,sig,sigmask)

vect = vert(vect);

tlock = [];
tlock.avg = vect;
tlock.dimord = 'chan_time';
tlock.label = label;
tlock.time = 1;
%if ~ischar(layout)
%   tlock.elec = layout; 
%end

if ischar(layout)
    cfg = []; cfg.layout = layout;
    layout = ft_prepare_layout(cfg);
end
cfg = [];
cfg.layout = layout;
cfg.interpolateovernan = 'yes';
cfg.lay = layout;
cfg.channel = label;
cfg.marker = 'off'; 
cfg.highlight = {'on','on'};
cfg.highlightchannel = {intersect(find(sig < 0.05),find(~sigmask)),find(sigmask)};
cfg.highlightsymbol = {'.','.'};
cfg.highlightcolor = {[0 0 0], [1 1 1]};
cfg.highlightsize = {[2],[7]};
cfg.comment = 'no'; cfg.interactive = 'no'; cfg.style = 'straight';

ft_topoplotER(cfg,tlock);

end