function EasyNIRS_ProcessOptExport(filenm)
global hmr

fid = fopen(filenm,'w');
for iFunc = 1:hmr.procInput.procFunc.nFunc
    fprintf(fid,'@ %s %s %s ',hmr.procInput.procFunc.funcName{iFunc},...
                              hmr.procInput.procFunc.funcArgOut{iFunc},...
                              hmr.procInput.procFunc.funcArgIn{iFunc});

    % Write out function user parameters
    if hmr.procInput.procFunc.nFuncParamVar(iFunc)
        fprintf(fid,'*');
    else
        for iP = 1:hmr.procInput.procFunc.nFuncParam(iFunc)
	  funcParamFormat = hmr.procInput.procFunc.funcParamFormat{iFunc}{iP};
            funcParamFormat(findstr(funcParamFormat,' '))='_';        
            if(funcParamFormat(end)=='_')
                funcParamFormat(end)=[];
            end
            funcParamVal = sprintf(sprintf(['%' hmr.procInput.procFunc.funcParamFormat{iFunc}{iP}]),...
                               hmr.procInput.procFunc.funcParamVal{iFunc}{iP});
            funcParamVal(findstr(funcParamVal,' '))='_';        
            if(funcParamVal(end)=='_')
                funcParamVal(end)=[];
            end
            fprintf(fid,'%s %s %s ',hmr.procInput.procFunc.funcParam{iFunc}{iP},...
                                    funcParamFormat,...
                                    funcParamVal);
        end
    end
    fprintf(fid,'\n');    
end
fclose(fid);
