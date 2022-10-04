function data = loadDataFromRun(filename,datatype)
global hmr

data=[];

if ~isfield(hmr,'group')
   return;
end

for ii=1:length(hmr.group)
   for jj=1:length(hmr.group(ii).subjs)
       for kk=1:length(hmr.group(ii).subjs(jj).runs)
           if strcmp(filename,hmr.group(ii).subjs(jj).runs(kk).filename)

               switch lower(datatype)
               case {'procinput'}
                   data = hmr.group(ii).subjs(jj).runs(kk).procInput;
               case {'userdata'}
                   data = hmr.group(ii).subjs(jj).runs(kk).userdata;
               end
           end
       end
   end
end
