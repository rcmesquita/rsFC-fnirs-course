function procStreamSave(filenm,procFunc)


fid = fopen(filenm,'w');

for iFunc=1:length(procFunc.funcName)
    fprintf( fid, '@ %s %s %s',...
        procFunc.funcName{iFunc}, procFunc.funcArgOut{iFunc}, ...
        procFunc.funcArgIn{iFunc} );
    for iParam=1:procFunc.nFuncParam(iFunc)
        fprintf( fid,' %s', procFunc.funcParam{iFunc}{iParam} );

        foos = procFunc.funcParamFormat{iFunc}{iParam};
        boos = sprintf( foos, procFunc.funcParamVal{iFunc}{iParam} );
        for ii=1:length(foos)
            if foos(ii)==' '
                foos(ii) = '_';
            end
        end
        for ii=1:length(boos)
            if boos(ii)==' '
                boos(ii) = '_';
            end
        end
        if ~strcmp(procFunc.funcParam{iFunc}{iParam},'*')
            fprintf( fid,' %s %s', foos, boos );        
        end
    end
    if procFunc.nFuncParamVar(iFunc)>0
        fprintf( fid,' *');
    end

    fprintf( fid, '\n' );
end

fclose(fid);
