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

wpm_list=[];


rmse_list=[];
theta_list=[];
beta_list=[];

for k=1:numel(d)
    k
  filename=fullfile(pat,d(k).name)
% filename='Trace_data_processed\ID2\kbtrace-log_a_tumor_is_ok_provided_it_is_benign_200218_012658.csv';


x_list=[];
y_list=[];
z_list=[];
t_list=[];



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

L=0.05;
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


key_index=sort(key_index);
idx1=key_index(4);
idx2=key_index(end-4);

x_list=[x_list,pos_list(idx1:idx2,1)];
y_list=[y_list,pos_list(idx1:idx2,2)];
z_list=[z_list,pos_list(idx1:idx2,3)];


    
[fitobject,gof] = fit([x_list, y_list],z_list,'poly11');

a=fitobject.p10;
b=fitobject.p01;
c=-1;
dd=-fitobject.p00;
normal=[a,b,c];
theta=rad2deg(atan(a/c));
beta=rad2deg(atan(b/sqrt(a^2+c^2)));
rmse=gof.rmse;


theta_list=[theta_list,theta];

beta_list=[beta_list,beta];

rmse_list=[rmse_list,rmse];

end

Y = quantile(beta_list,[0.25 0.50 0.75]);
q1=Y(1);
q2=Y(2);
q3=Y(3);

REC=[REC;[ID,q1,q2,q3]];

ALL=[ALL,beta_list];



end

save('plane_betaVar')

load('plane_betaVar')
figure(3);
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
ylabel('Beta ({\circ})','FontSize',35)
