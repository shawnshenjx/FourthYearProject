clear all
close all


% fid= fopen('new_phrases_total_new.txt','r');


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
% 
% 
% % phrase_list=string(phrase_list);
% fclose(fid)

std_list=[];
mean_list=[];

for ID = 1:1:20

pat1=sprintf('Trace_data_processed/ID%d',ID);

pat2=sprintf('Trace_data/ID%d/kbtrace',ID);
pat=pat1;

fil=fullfile(pat,'*.csv');
d=dir(fil);
L=0.05;

complete_list_list=[];


% 
% lower=0.04;
% step=0.01;
% upper=0.05;


final_z_list=[];
index_list=[];

% mean_id=[];
% std_id=[];
% 
% 
% tData = [];


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

    
    idx1=key_index(2);
    idx2=key_index(end-1);
    
    final_z=pos_list(idx1:idx2,3);

    final_z_list=[final_z_list;final_z];
    
    fclose(fid);
    

     
end
% mean_id=[mean_id,mean(final_z)];
% std_id=[std_id,std(final_z)];

mean_list=[mean_list,mean(final_z_list)];
std_list=[std_list,std(final_z_list)];
end

tiledlayout(2,1);

x=1:1:20;

nexttile
scatter(x,mean_list,'filled')
grid on 
xlabel('participant ID')
ylabel('depth mean')

nexttile
scatter(x,std_list,'filled')
grid on 
xlabel('participant ID')
ylabel('depth std')