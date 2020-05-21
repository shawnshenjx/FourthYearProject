clear all
close all

addpath('/Users/junxiaoshen/Desktop/Fourth Year Project/Functions')


addpath('/Users/junxiaoshen/Desktop/Fourth Year Project/Data')
% Open tracking log
filename = 'kb_qpz.csv';
fid = fopen(filename);

% Data to populate from file
tData = [];

% Read first line of file, discard header
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);

while ischar(tline)
    % Split data row into columns
    cols = str2double(strsplit(tline,','));
    
    % Assemble new data structure for sample
    data = struct;
    
    
    data.hmdPos = cols(7:9);
    data.hmdRot = cols(3:6);
    
    data.mPos = cols(10:12);
    data.t = cols(2);
    
    % Append sample
    tData = [tData; data];
    
    % Get next line
    tline = fgetl(fid);
end
% hmdPosmatrix=zeros(4,num);
% for i = 1:num
%     
% %   transmatrix = constructHT(roll,pitch,yaw,x,y,z);
%     hmdPos=tData.hmdPos;
%     hmdPosmatrix(i)=[hmdPos(i),1];
% %     =transmatrix*tData.hmdPos(i);
% end


N1 = size(tData,1);

hmdFrameH =[];
mvector=[];
% for i = 1:100:N
%     data = tData(i);
%    
%     hmdFrameH= [hmdFrameH ,convertvectors(data.hmdPos*1000,data.hmdRot)];
%     mvector=[mvector, [data.m1Pos(1)*1000,data.m1Pos(2)*1000,data.m1Pos(3)*1000,1]'];
%     
%     
% end
% 


for i = 1:1:N1
    data = tData(i);
   
%     [uaxis,vaxis,waxis,originpoint]= convertvectors(data.hmdPos*1000,data.hmdRot);

% 
%     quat = [0.7071 0.7071 0 0];
%     rotm = quat2rotm(quat);
%     uaxis = rotm(1,:);
%     vaxis = rotm(2,:);
%     waxis = rotm(3,:);
%     
    originpoint=data.hmdPos*1000;
%     offset=0;
%     originpoint(1:3)=originpoint(1:3)-offset*vaxis(1:3);
% 
%     oripoint=[0 0 0 1]';
%     Rmatrix=rotationmatrix(uaxis,vaxis,waxis,oripoint);

    R=quat2rotm(data.hmdRot);
    
    rotm=R;
    uaxis = rotm(1,:)';
    vaxis = rotm(2,:)';
    waxis = rotm(3,:)';


    mvector1=[data.mPos(1)*1000,data.mPos(2)*1000,data.mPos(3)*1000]';
    
    
    hmdFrameH= [hmdFrameH ,[R*[uaxis,vaxis,waxis],originpoint']];
    mvector=[mvector, R*mvector1];
    
end

filename = 'trace1.csv';
fid = fopen(filename);

% Data to populate from file
tData = [];

% Read first line of file, discard header
tline = fgetl(fid);
col = str2double(strsplit(tline,','));
data = struct;
data.kbPos=col(2:4);
data.kbRot=col(6:8);
tline = fgetl(fid);
tline = fgetl(fid);

cols1 = str2double(strsplit(tline,','));
initialtime=cols1(14);
while ischar(tline)
    % Split data row into columns
    cols = str2double(strsplit(tline,','));
    
    % Assemble new data structure for sample
    
    
    
    data.hmdPos = cols(11:13);
    data.hmdRot = cols(7:10);
    
    data.m1Pos = cols(1:3);
    data.m2Pos = cols(4:6);
    data.t = cols(14);
    
    % Append sample
    tData = [tData; data];
    
    % Get next line
    tline = fgetl(fid);
end






% hmdPosmatrix=zeros(4,num);
% for i = 1:num
%     
% %   transmatrix = constructHT(roll,pitch,yaw,x,y,z);
%     hmdPos=tData.hmdPos;
%     hmdPosmatrix(i)=[hmdPos(i),1];
% %     =transmatrix*tData.hmdPos(i);
% end

N2 = size(tData,1);%choose smaller value of n

kbFrameH =[];
m1vector=[];
m2vector=[];
% for i = 1:100:N
%     data = tData(i);
%    
%     hmdFrameH= [hmdFrameH ,convertvectors(data.hmdPos*1000,data.hmdRot)];
%     mvector=[mvector, [data.m1Pos(1)*1000,data.m1Pos(2)*1000,data.m1Pos(3)*1000,1]'];
%     
%     
% end
% 

for i = 1:1:N2
    data = tData(i);
%    
%     [uaxis,vaxis,waxis,originpoint]= convertvectors(data.hmdPos*1000,data.hmdRot);
%     Rmatrix=rotationmatrix(uaxis,vaxis,waxis,originpoint);
    
    originpoint=data.hmdPos*1000;
    
    R=eul2rotm(data.kbRot);
    
    rotm=R;
    uaxis = rotm(1,:)';
    vaxis = rotm(2,:)';
    waxis = rotm(3,:)';

    kbFrameH= [kbFrameH ,[R*[uaxis,vaxis,waxis],originpoint']];
    
    
    m1vector1=[data.m1Pos(1)*1000,data.m1Pos(2)*1000,data.m1Pos(3)*1000]';
    m1vector=[m1vector, R*m1vector1];
    
    
    m2vector1=[data.m2Pos(1)*1000,data.m2Pos(2)*1000,data.m2Pos(3)*1000]';
    m2vector=[m2vector, R*m2vector1];
    
end







N=min([N1 N2]);
kbFrameHf = [];
mvectorff=[];
m1vectorff=[];
m2vectorff=[];


for i = 1:4:(N*4)
    
    ia=(i+3)/4;
    oripoint=kbFrameH(:,i+3);
    
    Rmatrix=rotationmatrix(kbFrameH(:,i),kbFrameH(:,i+1),kbFrameH(:,i+2),oripoint(1:3));
    
    kbFrameHf= [kbFrameHf ,[Rmatrix*[kbFrameH(:,i),kbFrameH(:,i+1),kbFrameH(:,i+2)],kbFrameH(:,i+3)]];
    
    
    
    mvectorff=[mvectorff, Rmatrix*mvector(ia)];
    
    
    m1vectorff=[m1vector, Rmatrix*m1vector(ia)];
    
    
    m2vectorff=[m2vector, Rmatrix*m2vector(ia)];
    
    
end


