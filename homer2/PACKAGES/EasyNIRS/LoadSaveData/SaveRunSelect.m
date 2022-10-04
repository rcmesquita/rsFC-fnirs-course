function SaveRunSelect(run,paramsLst)

if isempty(paramsLst)
    return;
end

strLst = '''''';

for ii=1:length(paramsLst)

    switch paramsLst{ii}

    case {'d'}
        d = run.d;
        strLst = '''d''';

    case {'t'}
        t = run.t;
        strLst = [strLst ', ''t'''];
        
    case {'SD'}
        SD = run.SD;
        strLst = [strLst ', ''SD'''];

    case {'ml'}
        ml = run.SD.MeasList;
        strLst = [strLst ', ''ml'''];

    case {'s'}
        s = run.s;
        strLst = [strLst ', ''s'''];
        if data_diff(run.s,run.s0)
            s0 = run.s0;
            strLst = [strLst ', ''s0'''];
        end
        
    case {'aux'}
        aux = run.aux;
        strLst = [strLst ', ''aux'''];
        
    case {'tIncMan'}
        tIncMan = run.tIncMan;
        strLst = [strLst ', ''tIncMan'''];
        
    case {'userdata'}
        userdata = run.userdata;
        strLst = [strLst ', ''userdata'''];
        
    case {'procInput'}
        procInput = run.procInput;
        strLst = [strLst ', ''procInput'''];
        
    case {'procResult'}
        procResult = run.procResult;
        strLst = [strLst ', ''procResult'''];
        
    case {'CondNames'}
        CondNames = run.stim.CondNames;
        strLst = [strLst ', ''CondNames'''];
        
    end
end

eval( sprintf('save( [''./'' run.filename], %s, ''-mat'',''-append'')', strLst) );

