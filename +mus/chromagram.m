% MUS.CHROMAGRAM
%
% Copyright (C) 2014, 2017-2018 Olivier Lartillot
% Copyright (C) 2007-2012 Olivier Lartillot & University of Jyvaskyla
%
% All rights reserved.
% License: New BSD License. See full text of the license in LICENSE.txt in
% the main folder of the MiningSuite distribution.


%% Check scaling issue


function varargout = chromagram(varargin)
    varargout = sig.operate('mus','chromagram',initoptions,...
                            @init,@main,@after,varargin);
end


function options = initoptions
    options = sig.Signal.signaloptions('FrameAuto',.2,.05);
    
        cen.key = 'Center';
        cen.type = 'Boolean';
        cen.default = 0;
    options.cen = cen;
    
        nor.key = {'Normal','Norm'};
        nor.type = 'Numeric';
        nor.default = Inf;
    options.nor = nor;
    
        wth.key = 'Weight';
        wth.type = 'Numeric';
        wth.default = .5;
    options.wth = wth;
    
        tri.key = 'Triangle';
        tri.type = 'Boolean';
        tri.default = 0;
    options.tri = tri;
    
        wrp.key = 'Wrap';
        wrp.type = 'Boolean';
        wrp.default = 1;
        wrp.when = 'After';
    options.wrp = wrp;
    
        plabel.key = 'Pitch';
        plabel.type = 'Boolean';
        plabel.default = 1;
    options.plabel = plabel;
    
        thr.key = {'Threshold','dB'};
        thr.type = 'Numeric';
        thr.default = 20;
    options.thr = thr;
    
        min.key = 'Min';
        min.type = 'Numeric';
        min.default = 100;
    options.min = min;
    
        max.key = 'Max';
        max.type = 'Numeric';
        max.default = 5000;
    options.max = max;

        res.key = 'Res';
        res.type = 'Numeric';
        res.default = 12;
        res.when = 'Both';
    options.res = res;

        origin.key = 'Tuning';
        origin.type = 'Numeric';
        origin.default = 261.6256;
    options.origin = origin;
    
        transp.key = 'Transpose';
        transp.type = 'Numeric';
        transp.default = 0;
    options.transp = transp;
end


%%
function [x type] = init(x,option,frame)
    if ~isa(x,'mus.Sequence') && ~istype(x,'mus.Chromagram')
        if x.istype('sig.Signal')
            if option.frame
                x = sig.frame(x,'FrameSize',option.fsize.value,option.fsize.unit,...
                    'FrameHop',option.fhop.value,option.fhop.unit);
            end
        end
        
        freqmin = option.min;
        freqmax = freqmin*2;
        while freqmax < option.max
            freqmax = freqmax*2;
        end
        x = {sig.spectrum(x,'dB',option.thr,'Min',freqmin,'Max',freqmax,...
                          'MinRes',option.res,'OctaveRatio',.85),...  % NormalInput missing
             x};
        if isa(x{2},'sig.design')
            x{2}.symbolicinput = 1;
        end
    end
    type = {'mus.Chromagram','sig.Spectrum'};
end


function out = main(in,option)
    if iscell(in)
        if isa(in{1},'mus.Chromagram')
            out = in;
        else
            in = in{1};
            if option.res == 12
                chromascale = {'C','C#','D','D#','E','F','F#','G','G#','A','A#','B'};
            else
                chromascale = 1:option.res;
                option.plabel = 0;
            end
            [m,c,p,fc,on] = sig.compute(@routine,in.Ydata,in.xdata,option,chromascale);
            chro = mus.Chromagram(m,'ChromaClass',c,'XData',p,...
                'ChromaFreq',fc,'Register',on,...
                'Srate',in.Srate,'Ssize',in.Ssize,...
                'Sstart',in.Sstart,'Send',in.Send,...
                'FbChannels',in.fbchannels);
            chro.Xaxis.unit.rate = 1;
            out = {chro in};
        end
    else
        c = zeros(length(in.content),1);
        on = zeros(length(in.content),1);
        off = zeros(length(in.content),1);
        for i = 1:length(in.content)
            c(i) = in.content{i}.parameter.getfield('chro').value;
            on(i) = in.content{i}.parameter.getfield('onset').value;
            off(i) = in.content{i}.parameter.getfield('offset').value;
        end
        chro = min(c):max(c);
        c = c - chro(1) + 1;
        if option.frame
            if strcmpi(option.fsize.unit,'s')
                l = option.fsize.value;
            elseif strcmpi(option.fsize.unit,'sp')
                error('Error: ''sp'' not adequate for symbolic data');
            end
            if strcmpi(option.fhop.unit,'/1')
                h = option.fhop.value*l;
            elseif strcmpi(option.fhop.unit,'%')
                h = option.fhop.value*l*.01;
            elseif strcmpi(option.fhop.unit,'s')
                h = option.fhop.value;
            elseif strcmpi(option.fhop.unit,'sp')
                error('Error: ''sp'' not adequate for symbolic data');
            elseif strcmpi(option.fhop.unit,'Hz')
                h = 1/option.fhop.value;
            end
            nfr = floor((max(off)-l)/h)+1; % Number of frames
        else
            nfr = 0;
        end
        if nfr
            srate = 1/h;
            m = zeros(length(chro),nfr);
            for i = 1:nfr
                st = (i-1)*h;
                en = st + l;
                
                f = find(off >= st,1);
                c(1:f-1) = [];
                on(1:f-1) = [];
                off(1:f-1) = [];

                f = find(on > en,1);
                for j = 1:f-1
                    onj = max(on(j),st);
                    offj = min(off(j),en);
                    m(c(j),i) = m(c(j),i) + offj - onj;
                end
            end
        else
            srate = 0;
            m = zeros(length(chro),1);
            for i = 1:length(in.content)
                m(c(i)) = m(c(i)) + off(i) - on(i);
            end
        end
        chro = mod(chro,12);
        m = sig.data(m,{'element','sample'});
        fc = [];
        on = [];
        chro = mus.Chromagram(m,'ChromaClass',chro,...%'XData',p
            'ChromaFreq',fc,'Register',on,...
            'Srate',srate,'Ssize',nfr,...
            'FbChannels',1);
        chro.Xaxis.unit.rate = 1;
        out = {chro};  
    end
end


function out = routine(m,f,option,chromascale)
    % Let's remove the frequencies exceeding the last whole octave.
    minf = min(min(min(f)));
    maxf = max(max(max(f)));
    maxf = minf*2^(floor(log2(maxf/minf)));
    fz = find(f > maxf);
    f(fz) = [];
        
    c = freq2chro(f,option.res,option.origin);
    if not(ismember(min(c)+1,c))
        warning('WARNING IN MUS.CHROMAGRAM: Frequency resolution of the spectrum is too low.');
        display('The conversion of low frequencies into chromas may be incorrect.');
    end
    cc = min(min(min(c))):max(max(max(c)));
    sc = length(cc);   % The size of range of absolute chromas.
    mat = zeros(length(f),sc);
    fc = chro2freq(cc,option.res,option.origin);   % The absolute chromas in Hz.
    fl = chro2freq(cc-1,option.res,option.origin); % Each previous chromas in Hz.
    fr = chro2freq(cc+1,option.res,option.origin); % Each related next chromas in Hz.
    for k = 1:sc
        rad = find(and(f > fc(k)-option.wth*(fc(k)-fl(k)),...
            f < fc(k)-option.wth*(fc(k)-fr(k))));
        if option.tri
            dist = fc(k) - f(:,1,1,1);
            rad1 = dist/(fc(k) - fl(k))/option.wth;
            rad2 = dist/(fc(k) - fr(k))/option.wth;
            ndist = max(rad1,rad2);
            mat(:,k) = max(min(1-ndist,1),0)/length(rad);
        else
            mat(rad,k) = ones(length(rad),1)/length(rad);
        end
        if k ==1 || k == sc
            mat(:,k) = mat(:,k)/2;
        end
    end
    c = mod(cc',option.res);
    o = floor(cc/option.res)+4;
    if option.plabel
        p = strcat(chromascale(c+1)',num2str(o'));
    else
        p = cc'+60;
    end
    m = m.apply(@algo,{mat,fz},{'element'},1);
    out = {m,c,p,fc,o};
end


function m = algo(m,mat,fz)
    m(fz) = [];
    m = m'*mat;
    m = m';
end


function c = freq2chro(f,res,origin)
    c = round(res*log2(f/origin));
end


function f = chro2freq(c,res,origin)
    f = 2.^(c/res)*origin;
end


%%
function x = after(x,option)
    x = x{1};
    if option.wrp && ~x.wrap
        x.Ydata = sig.compute(@wrap,x.Ydata,x.chromaclass,option.res);
        x.wrap = 1;
        x.xunsampled = {'C';'C#';'D';'D#';'E';'F';'F#';'G';'G#';'A';'A#';'B'};
    end
    if option.cen
        x.Ydata = sig.compute(@center,x.Ydata);
    end
    if option.nor
        x.Ydata = sig.compute(@norm,x.Ydata,option.nor);
    end
    x = {x};
end


function x = wrap(x,cc,res)
    x = x.apply(@wrap_algo,{cc,res},{'element'},1);
end


function m2 = wrap_algo(m,cc,res)
    m2 = zeros(res,1);
    for i = 1:length(m)
        m2(cc(i)+1) = m2(cc(i)+1) + m(i);
    end
end


function x = center(x)
    x = x.apply(@center_algo,{},{'element'},1);
end


function m = center_algo(m)
    m = m-mean(m);
end


function x = norm(x,p)
    x = x.apply(@norm_algo,{p},{'element'},1);
end


function m = norm_algo(m,p)
    m = m ./ (vectnorm(m,p) + 1e-6);
end


function y = vectnorm(x,p)
    if isinf(p)
        y = max(x);
    else
        y = sum(abs(x).^p).^(1/p);
    end
end