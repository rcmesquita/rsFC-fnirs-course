function Create_Probe_file(filename,SrcPos,DetPos,MeasList,)

Lambda=[690 830];
nSrc=size(SrcPos,1);
nDets=size(DetPos,1);


save(filename, 'SD', '-mat');

fd = fopen([filename(1:end-4) '_labels.txt'], 'wt');
for ii=1:length(refpts.labels)
    fprintf(fd, '%s\n', refpts.labels{ii});
end
fclose(fd);


