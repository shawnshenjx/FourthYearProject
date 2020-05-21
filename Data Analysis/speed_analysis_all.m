clear all
close all


% fid= fopen('new_phrases_total_new.txt','r');
% 
% 
% tline = fgetl(fid);
% 
% phrase_list=[];
% 
% while ischar(tline)
%     % Split data row into columns
% 
%     cols = split(tline);
%     phrase=replace(lower(string(join(cols(4:end)))),' ','_');
%     
%     phrase_list=[phrase_list,phrase];
%     
%     tline = fgetl(fid);
%     if isempty(tline)
%         break
%     end
% 
% end


% phrase_list=string(phrase_list);
% fclose(fid)

wpm_list_all=[];


for ID = 1:1:20

pat1=sprintf('Trace_data_processed/ID%d',ID);

pat2=sprintf('Trace_data/ID%d/kbtrace',ID);
pat=pat1;

fil=fullfile(pat,'*.csv');
d=dir(fil);


% if pat==string(sprintf('Trace_data_processed/ID%d',ID))
    
TData=[];

wpm_list=[];

for k=1:numel(d)
    filename=fullfile(pat,d(k).name);
%     filename='Trace_data_processed/ID20/kbtrace-log_you_have_my_sympathy_200227_034817.csv';

    fid = fopen(filename);

    % Data to populate from file
    tData = [];

    % Read first line of file, discard header
    tline = fgetl(fid);

    while ischar(tline)
        % Split data row into columns
        
        cols = str2double(strsplit(tline,' '));
        

        % Assemble new data structure for sample
        data = struct;

        data.mPos = cols(1:3);
        data.t = cols(4);

        % Append sample
        tData = [tData; data];

        % Get next line
        tline = fgetl(fid);
        if isempty(tline)
            break
        end
    
    end

    N = size(tData,1);
    
    
    
    
    phrase_split=split(filename,'_');
    phrase_split=phrase_split(4:end-2);
    message=split(join(phrase_split),'');
    
    
    letter_list=string(replace(join(phrase_split),' ','_'));
    num_words=(size(message,1)-2)/5;
    
    time=tData(end).t-tData(1).t;
    wpm=num_words/(time/(1000*60));
    
    wpm_list=[wpm_list,wpm];
    
%     data=struct;
%     data.index_list=find(phrase_list==letter_list);
%     
%    
%     
%     data.wpm=wpm;
%     TData = [TData; data];
%     
    fclose(fid)
end

wpm_list_all=[wpm_list_all,mean(wpm_list)];


end



% 
% 
% TDATA=[];
% for i =1:1:1050
% for j = 1:1:size(TData,1)
% %     tData(j).index_list
%     
%     if TData(j).index_list==i
%         i;
%         Data=struct;
%         
%         
%         Data.index=TData(j).index_list;
%         
%         Data.wpm=TData(j).wpm;
%        
%         TDATA=[TDATA,Data];
%     end
% end
% end
% 
% 
% wpm_list=[];
% 
% 
% for i =1:1:size(TDATA,2)
%     
%     Data=TDATA(i);
%     wpm_list=[wpm_list,Data.wpm];
% 
% 
% end


x=1:1:20;
scatter(x,wpm_list_all/9,'filled')
grid on 
xlabel('participant ID')
ylabel('entry rate (wpm)')
max(wpm_list_all)
min(wpm_list_all)
std(wpm_list_all)