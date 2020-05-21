clear all
close all


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

REC=[];
ALL=[];
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


wpm_list=[];


% for i =1:1:size(TDATA,2)
%     
%     Data=TDATA(i);
%     wpm_list=[wpm_list,Data.wpm];
% 
% 
% end

for i =1:1:size(TData,1)
    
    Data=TData(i);
    wpm_list=[wpm_list,Data.wpm];


end


Y = quantile(wpm_list,[0.25 0.50 0.75]);
q1=Y(1);
q2=Y(2);
q3=Y(3);

REC=[REC;[ID,q1,q2,q3]];

ALL=[ALL,wpm_list];



end
save('speed_analysisQVar')

load('speed_analysisQVar')
set(gcf,'position',[150 150 1500 600])
REC_sorted=sortrows(REC,3);

for i =1:size(REC_sorted,1)
    w=1;
    h=REC_sorted(i,4)-REC_sorted(i,2);
    h2=REC_sorted(i,3)-REC_sorted(i,2);
    rectangle('Position',[i-0.5 REC_sorted(i,2) w h ])
    rectangle('Position',[i-0.5 REC_sorted(i,3) w 0.0001 ],'FaceColor','r')
end

Y = quantile(ALL,[0.25 0.50 0.75]);
Q1=Y(1);
Q2=Y(2);
Q3=Y(3);

rectangle('Position',[0.5 Q1 20 (Q3-Q1)],'EdgeColor','b','LineWidth',1)
rectangle('Position',[0.5 Q2 20 0.0001],'FaceColor',[0 .5 .5])

xticks(1:1:20);
xtickl=string(REC_sorted(:,1));
xticklabels(xtickl);


set(gca,'FontSize',30);
xlabel('Participant ID','FontSize',35)
ylabel('Entry Rate (WPM)','FontSize',35)