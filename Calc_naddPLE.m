function Calc_naddPLE(settings,freqdata,filename)

if strcmpi(settings.tfparams.method,'hilbert')
    prestim_pseudo = settings.pseudo.prestim;
    prestim_real = settings.real.prestim;
    poststim_pseudo = settings.pseudo.poststim;
    poststim_real = settings.real.poststim;
else
    prestim_pseudo = settings.pseudo.prestim - settings.pseudo.prestim(1)+1+ceil(settings.srate/5);
    prestim_real = settings.real.prestim - settings.pseudo.prestim(1)+1+ceil(settings.srate/5);
    poststim_pseudo = settings.pseudo.poststim - settings.pseudo.prestim(1)+1+ceil(settings.srate/5);
    poststim_real = settings.real.poststim - settings.pseudo.prestim(1)+1+ceil(settings.srate/5);
end

pledata = cell(1,size(freqdata.fourierspctrm,1));
intdata = pledata;

frange = intersect(find(freqdata.freq > settings.tfparams.fbands{2}(1)),...
    find(freqdata.freq < settings.tfparams.fbands{end}(2)));

for i = 1:size(freqdata.fourierspctrm,1)
    for ii = 1:size(freqdata.fourierspctrm,2)
        for iii = 1:size(freqdata.fourierspctrm,4)
            tmp = log10(freqdata.freq(frange));
            pow = log10(squeeze(freqdata.fourierspctrm(i,ii,frange,iii)));
            lintmp = vert(linspace(tmp(1),tmp(end),length(tmp)));
            pow = interp1(tmp,pow,lintmp);
            p = polyfit(lintmp,pow,1);
            pledata{i}(1,ii,iii) = -p(1);
            intdata{i}(1,ii,iii) = 10.^p(2);
        end
    end
end

pledata = cat(1,pledata{:});
intdata = cat(1,intdata{:});

pledata = permute(pledata,[2 3 1]);
intdata = permute(intdata,[2 3 1]);

split_real = squeeze(mean(pledata(:,prestim_real,:),2));
split_pseudo = squeeze(mean(pledata(:,prestim_pseudo,:),2));

for c = 1:settings.nbchan
    splitindex = split_pseudo(c,:) > median(split_pseudo(c,:));
    
    naple.raw.pseudo(c,:,1) = mean(pledata(c,:,find(~splitindex)),3);
    naple.raw.pseudo(c,:,2) = mean(pledata(c,:,find(splitindex)),3);
    
    naple.pseudo(c,:,1) = (mean(pledata(c,poststim_pseudo,find(~splitindex)),3)...
        -mean(mean(pledata(c,prestim_pseudo,find(~splitindex)),3),2));
    naple.pseudo(c,:,2) = (mean(pledata(c,poststim_pseudo,find(splitindex)),3)...
        -mean(mean(pledata(c,prestim_pseudo,find(splitindex)),3),2));
    
    switch settings.units
        case 'prcchange'
            naple.pseudo(c,:,1) = 100*naple.pseudo(c,:,1)./mean(mean(pledata(c,prestim_pseudo,:),3),2);
            naple.pseudo(c,:,2) = 100*naple.pseudo(c,:,2)./mean(mean(pledata(c,prestim_pseudo,:),3),2);
        case 'zscore'
            naple.pseudo(c,:,1) = zscore(naple.pseudo(c,:,1),0,2);
            naple.pseudo(c,:,2) = zscore(naple.pseudo(c,:,2),0,2);
        case 'log'
            naple.pseudo(c,:,1) = 10*log10(naple.pseudo(c,:,1));
            naple.pseudo(c,:,2) = 10*log10(naple.pseudo(c,:,2));
    end
    
    splitindex = split_real(c,:) > median(split_real(c,:));
    
    naple.raw.real(c,:,1) = mean(pledata(c,:,find(~splitindex)),3);
    naple.raw.real(c,:,2) = mean(pledata(c,:,find(splitindex)),3);
    
    naple.real(c,:,1) = (mean(pledata(c,poststim_real,find(~splitindex)),3)...
        -mean(mean(pledata(c,prestim_real,find(~splitindex)),3),2));
    naple.real(c,:,2) = (mean(pledata(c,poststim_real,find(splitindex)),3)...
        -mean(mean(pledata(c,prestim_real,find(splitindex)),3),2));
    
    switch settings.units
        case 'prcchange'
            naple.real(c,:,1) = 100*naple.real(c,:,1)./mean(mean(pledata(c,prestim_real,:),3),2);
            naple.real(c,:,2) = 100*naple.real(c,:,2)./mean(mean(pledata(c,prestim_real,:),3),2);
        case 'zscore'
            naple.real(c,:,1) = zscore(naple.real(c,:,1),0,2);
            naple.real(c,:,2) = zscore(naple.real(c,:,2),0,2);
        case 'log'
            naple.real(c,:,1) = 10*log10(naple.real(c,:,1));
            naple.real(c,:,2) = 10*log10(naple.real(c,:,2));
    end
    
    naple.diff = naple.real - naple.pseudo;
end

split_real = squeeze(mean(intdata(:,prestim_real,:),2));
split_pseudo = squeeze(mean(intdata(:,prestim_pseudo,:),2));

for c = 1:settings.nbchan
    splitindex = split_pseudo(c,:) > median(split_pseudo(c,:));
    
    naint.raw.pseudo(c,:,1) = mean(intdata(c,:,find(~splitindex)),3);
    naint.raw.pseudo(c,:,2) = mean(intdata(c,:,find(splitindex)),3);
    
    naint.pseudo(c,:,1) = (mean(intdata(c,poststim_pseudo,find(~splitindex)),3)...
        -mean(mean(intdata(c,prestim_pseudo,find(~splitindex)),3),2));
    naint.pseudo(c,:,2) = (mean(intdata(c,poststim_pseudo,find(splitindex)),3)...
        -mean(mean(intdata(c,prestim_pseudo,find(splitindex)),3),2));
    
    switch settings.units
        case 'prcchange'
            naint.pseudo(c,:,1) = 100*naint.pseudo(c,:,1)./mean(mean(intdata(c,prestim_pseudo,:),3),2);
            naint.pseudo(c,:,2) = 100*naint.pseudo(c,:,2)./mean(mean(intdata(c,prestim_pseudo,:),3),2);
        case 'zscore'
            naint.pseudo(c,:,1) = zscore(naint.pseudo(c,:,1),0,2);
            naint.pseudo(c,:,2) = zscore(naint.pseudo(c,:,2),0,2);
        case 'log'
            naint.pseudo(c,:,1) = 10*log10(naint.pseudo(c,:,1));
            naint.pseudo(c,:,2) = 10*log10(naint.pseudo(c,:,2));
    end
    
    splitindex = split_real(c,:) > median(split_real(c,:));
    
    naint.raw.real(c,:,1) = mean(intdata(c,:,find(~splitindex)),3);
    naint.raw.real(c,:,2) = mean(intdata(c,:,find(splitindex)),3);
    
    naint.real(c,:,1) = (mean(intdata(c,poststim_real,find(~splitindex)),3)...
        -mean(mean(intdata(c,prestim_real,find(~splitindex)),3),2));
    naint.real(c,:,2) = (mean(intdata(c,poststim_real,find(splitindex)),3)...
        -mean(mean(intdata(c,prestim_real,find(splitindex)),3),2));
    
    switch settings.units
        case 'prcchange'
            naint.real(c,:,1) = 100*naint.real(c,:,1)./mean(mean(intdata(c,prestim_real,:),3),2);
            naint.real(c,:,2) = 100*naint.real(c,:,2)./mean(mean(intdata(c,prestim_real,:),3),2);
        case 'zscore'
            naint.real(c,:,1) = zscore(naint.real(c,:,1),0,2);
            naint.real(c,:,2) = zscore(naint.real(c,:,2),0,2);
        case 'log'
            naint.real(c,:,1) = 10*log10(naint.real(c,:,1));
            naint.real(c,:,2) = 10*log10(naint.real(c,:,2));
    end
    
    naint.diff = naint.real - naint.pseudo;
end


save(fullfile(settings.outputdir,[settings.datasetname '_' filename '_naddPLE.mat']),'naple','pledata','naint','intdata','-v7.3')

end