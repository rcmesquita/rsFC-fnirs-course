function SaveDataToRun(filename,varargin)
global hmr

strLst = [];
bf=0;
for ii=1:length(hmr.group)
    for jj=1:length(hmr.group(ii).subjs)
        for kk=1:length(hmr.group(ii).subjs(jj).runs)
            if strcmp(filename,hmr.group(ii).subjs(jj).runs(kk).filename)

                for iArg=1:2:length(varargin)

                    datatype = varargin{iArg};
                    data = varargin{iArg+1};

                    switch datatype
                    case {'procInput'}
                        procInput = data;
                        hmr.group(ii).subjs(jj).runs(kk).procInput = procInput;

                        strLst = ['''procInput'',' strLst];
                        if procInput.changeFlag > 0;
                            hmr.group(ii).procInput.changeFlag = 1;
                            hmr.group(ii).subjs(jj).procInput.changeFlag = 1;
                        end
                    case {'userdata'}
                        userdata = data;
                        strLst = ['''userdata'',' strLst];
                    case {'procResult'}
                        procResult = data;
                        strLst = ['''procResult'',' strLst];
                    case {'SD'}
                        SD = data;
                        strLst = ['''SD'',' strLst];
                    case {'s'}
                        s = data;
                        strLst = ['''s'',' strLst];
                    case {'tIncMan'}
                        tIncMan = data;
                        strLst = ['''tIncMan'',' strLst];
                    end

                end
                bf=1; break;
            end
        end
        if bf==1
            break;
        end
    end
    if bf==1
        break;
    end
end
if ~isempty(strLst)
    k=findstr(strLst,',');
    strLst(k(end))=[];
    eval(sprintf('save(hmr.group(ii).subjs(jj).runs(kk).filename, %s, ''-mat'',''-append'')', strLst) );
end
