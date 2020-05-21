

fid= fopen('new_phrases_total_new.txt','r');


tline = fgetl(fid);

phrase_list=[];

while ischar(tline)
    % Split data row into columns

    cols = split(tline);
    phrase=replace(lower(string(join(cols(4:end)))),' ','_');
    
    phrase_list=[phrase_list,phrase];
    
    tline = fgetl(fid);
    if isempty(tline)
        break
    end

end


% phrase_list=string(phrase_list);
fclose(fid)