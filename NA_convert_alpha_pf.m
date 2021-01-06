function [fbands,pf] = NA_convert_alpha_pf(settings,data)

fbands = settings.tfparams.fbands;
pf = 10;

if any(contains(settings.tfparams.fbandnames,{'Theta','Alpha','Beta'}))
individ = {'Theta','Alpha','Beta'};
for i = 1:3
if any(contains(settings.tfparams.fbandnames,individ{i}))
individindx(i) = find(strcmpi(settings.tfparams.fbandnames,individ{i}));
else
individindx(i) = NaN;
end
end
%individindx = Subset_index(settings.tfparams.fbandnames,individ);

[psum,~,f] = restingIAF(data.trial{1},length(data.label),3,[1 40],500,[7 14],11,5);

if ~isnan(psum.paf)
    pf = psum.paf;
else
    pf = psum.cog;
end

if isempty(pf) || isnan(pf)
   pf = 10;
   f = [8 13]; 
   psum.iaw = [1 2];
end


if ~isnan(individindx(2))
if f(psum.iaw(1)) < f(psum.iaw(2))
    fbands{individindx(2)} = [f(psum.iaw(1)) f(psum.iaw(2))];
end
end
if ~isnan(individindx(1))
if settings.tfparams.fbands{individindx(1)}(1) < f(psum.iaw(1))
    fbands{individindx(1)} = [settings.tfparams.fbands{individindx(1)}(1) f(psum.iaw(1))];
end
end
if ~isnan(individindx(3))
if f(psum.iaw(2)) < settings.tfparams.fbands{individindx(3)}(2)
    fbands{individindx(3)} = [f(psum.iaw(2)) settings.tfparams.fbands{individindx(3)}(2)];
end
end
end
