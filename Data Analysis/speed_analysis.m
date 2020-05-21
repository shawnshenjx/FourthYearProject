clear all
close all


fid= fopen('new_phrases_total_new.txt','r');

set(gcf,'position',[150 150 1000 1000])
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

mean_DATA=[];
for ID =1:1:20

pat1=sprintf('Trace_data_processed/ID%d',ID);

pat2=sprintf('Trace_data/ID%d/kbtrace',ID);
pat=pat1;

fil=fullfile(pat,'*.csv');
d=dir(fil);


% if pat==string(sprintf('Trace_data_processed/ID%d',ID))
    
TData=[];


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
    
    
    data=struct;
    data.index_list=find(phrase_list==letter_list);
    
   
    
    data.wpm=wpm;
    TData = [TData; data];
    fclose(fid)

end



TDATA=[];
for i =1:1:1050
for j = 1:1:size(TData,1)
%     tData(j).index_list
    
    if TData(j).index_list==i
        i;
        Data=struct;
        
        
        Data.index=TData(j).index_list;
        
        Data.wpm=TData(j).wpm;
       
        TDATA=[TDATA,Data];
    end
end
end


wpm_list=[];


for i =1:1:size(TDATA,2)
    
    Data=TDATA(i);
    if isnan(Data.wpm)
        continue
    end
    wpm_list=[wpm_list,Data.wpm];


end


mean_data=struct;
mean_data.wpm_list=wpm_list;
mean_DATA=[mean_DATA;mean_data];

% x_axis=1:10:numel(d);

fclose('all')



% x_axis=1:10:numel(d);
% plot(x_axis,wpm_list,'-o')
% 
% hold on
end
for i = 1:20
    a=mean_DATA(i).wpm_list;
    speed_mean=mean(reshape(a(1:45),[9,5]));


    plot(speed_mean,'-o')

    hold on


end


set(gca,'FontSize',30);
ylabel('Mean Entry Rate (WPM)','FontSize',35)
xlabel('Phrase ID','FontSize',35)


xticks([1 2 3 4 5])
xticklabels({'1-9','10-18','19-27','28-36','37-45'})