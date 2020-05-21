
clear all
close all
fclose('all')

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


% TTData=[];
REC=[];
ALL=[];

for ID =1:1:20

pat1=sprintf('Trace_data_processed/ID%d',ID);

pat2=sprintf('Trace_data/ID%d/kbtrace',ID);
pat=pat1;

fil=fullfile(pat,'*.csv');
d=dir(fil);
L=0.05;
complete_list_list=[];

lower=0.04;
step=0.01;
upper=0.05;

if pat==string(sprintf('Trace_data_processed/ID%d',ID))
    

final_z_list=[];
index_list=[];

tData = [];


for k=1:numel(d)
    filename=fullfile(pat,d(k).name);
%     filename='Trace_data_processed/ID20/kbtrace-log_you_have_my_sympathy_200227_034817.csv';
  



    load('M.mat')

    fid = fopen(filename);

    % Data to populate from file
    x_pos = [];
    y_pos = [];
    z_pos = [];
    t_list = [];
    pos_list=[];
    % Read first line of file, discard header
    tline = fgetl(fid);


    while ischar(tline)
        % Split data row into columns
        
        cols = str2double(strsplit(tline,' '));
        data = struct;
        x_pos =[x_pos,cols(1)];
        y_pos =[y_pos,cols(2)];
        z_pos =[z_pos,cols(3)];
        pos_list=[pos_list;cols(1:3)];
        t_list =[t_list,cols(4)];

        tline = fgetl(fid);
        if isempty(tline)
            break
        end
    end

    N = size(x_pos,2);


    phrase_split_=split(filename,'_');
    phrase_split=phrase_split_(4:end-2);
    splitmessage=split(replace(join(phrase_split),' ','_'),'');

    C1= transpose(splitmessage(2:end-1));



    A1=size(C1);
    A1=A1(2);
    keySet1=strings(1,A1);

    valueSet1=zeros(1,A1);
    for i = 1:1:A1
        keySet1(i)=C1(i);
        valueSet1(i) = i;
    end
    M2  = containers.Map(valueSet1,keySet1);
    M3  = containers.Map(keySet1,valueSet1);
    
    L_d=0.05;
    L_v=0.1;
    kbScale=0.0001;

    index=1;

    letter_list='';
    key_index=[];
    for i = 1:1:N
        x=x_pos(i);
        y=y_pos(i);
        z=z_pos(i);
              
        len=size(keySet1);
        len=len(2);

        key_=M2(index);
        keypos=cell2mat(M(key_));

        keypos1=[keypos(1:2)*kbScale,0];

        a=keypos1(1);
        b=keypos1(2);
        c=keypos1(3);
        keypos2=transpose([-a ,b,c]);
        pos_d=transpose([x,y,z]);

        pos=transpose([x,y,0]);
       
        if norm(pos-keypos2) <L && index<=A1 && abs(pos_d(3))<L_v
            x_index=find(x_pos==pos(1));
            y_index=find(y_pos==pos(2));
            xy_index=[x_index,y_index];
            start_index=mode(xy_index(:));
            key_index=[key_index,start_index];
            letter=M2(index);
            letter_list=append(letter_list,string(letter));
            index=index+1;
        end
        
        if index==A1+1
            break
        end
    end
    
    index_list=[index_list,find(phrase_list==letter_list)];
    
    data=struct;
    find_index=find(phrase_list==letter_list);
    
    data.index_list=find_index(1);
    
   
    idx1=key_index(2);
    idx2=key_index(end-1);
    
    final_z=pos_list(idx1:idx2,3);
    data.final_z=final_z;
    tData = [tData; data];
%     final_z_list=[final_z_list;transpose(final_z)];
%     mean_id=[mean_id,mean(final_z)];
%     std_id=[std_id,std(final_z)];
    
    
    

end


% T=table(index_list,final_z_list);
end



TData=[];

for i =1:1:1050
for j = 1:1:size(tData,1)
%     tData(j).index_list
    
    if tData(j).index_list==i
        i;
        Data=struct;
        Data.ID=ID;
        
        Data.index=tData(j).index_list;
        
        Data.z=tData(j).final_z;
        
        TData=[TData,Data];
    end
end
end


% 
% TTData=[TTData,TData];


mean_id=[];

% for i =1:1:size(TData,2)
%     
%     Data=TData(i);
%     mean_id=[mean_id,mean(Data.z)];
%     
% end


for i =1:1:size(tData,1)
    
    Data=tData(i);
    mean_id=[mean_id,mean(Data.final_z)];
    
end


Y = quantile(mean_id,[0.25 0.50 0.75]);
q1=Y(1);
q2=Y(2);
q3=Y(3);

REC=[REC;[ID,q1,q2,q3]];

ALL=[ALL,mean_id];



fclose('all')
end

save('depth_analysisQVar')

load('depth_analysisQVar')
set(gcf,'position',[150 150 1500 600])
REC_sorted=sortrows(REC,3);

for i =1:size(REC_sorted,1)
    w=1;
    h=REC_sorted(i,4)-REC_sorted(i,2);
    h2=REC_sorted(i,3)-REC_sorted(i,2);
    rectangle('Position',[i-0.5 REC_sorted(i,2) w h ])
    rectangle('Position',[i-0.5 REC_sorted(i,3) w 0.0001  ],'FaceColor','r')
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
ylabel('Depth to Keyboard ({m})','FontSize',35)





