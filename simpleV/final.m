clear all

close all

addpath('Functions')


addpath('NEWDATA')
% Open tracking log

layoutFile = 'holokeyboard.txt';
kbScale = 0.1;
[keys] = parseLayout(layoutFile);

filename = 'hello_world_slowOP.csv';
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
    

    offset=[0 0.05 0.03];
    data.hmdPos = (cols(7:9)-offset)*1000;
    data.hmdRot = cols(3:6);
    
    data.mPos = cols(10:12)*1000;
    data.t = cols(2);
    
    % Append sample
    tData = [tData; data];
    
    % Get next line
    tline = fgetl(fid);
end

N1 = size(tData,1);








filename = 'hello_world_slow.csv';




fid = fopen(filename);

% Data to populate from file
tData1 = [];

% Read first line of file, discard header
tline = fgetl(fid);
col = str2double(strsplit(tline,','));
data1 = struct;
data1.kbPos=col(2:4)*1000;
data1.kbRot=col(6:9);
tline = fgetl(fid);
tline = fgetl(fid);

cols1 = str2double(strsplit(tline,','));
initialtime=cols1(14);
while ischar(tline)
    % Split data row into columns
    cols = str2double(strsplit(tline,','));
    
    % Assemble new data structure for sample
    
    
    
    
    
    data1.hmdPos = cols(7:9)*1000;
    data1.hmdRot = cols(10:13);
    
    data1.m1Pos = cols(1:3)*1000;
    data1.m2Pos = cols(4:6)*1000;
    data1.t = cols(14);
    
    % Append sample
    tData1 = [tData1; data1];
    
    % Get next line
    tline = fgetl(fid);
end













% type holokeyboard.txt;


fileID = fopen('holokeyboard.txt','r');

C = textscan(fileID,'%s %f %f %f %f','Delimiter',';');

A=size(C{1});
keySet=strings(1,A(1));


keySet(1)=C{1}{1};
valueSet=cell(1,A(1));

xcenter=C{2}(1);
ycenter=C{3}(1);
width=C{4}(1);
height=C{5}(1);

valueSet{1}{1} = [xcenter,ycenter,width,height];
for i = 2:1:A(1)
    keySet(i)=C{1}{i};
        

    xcenter=C{2}(i);
    ycenter=C{3}(i);
    width=C{4}(i);
    height=C{5}(i);
    
    valueSet{i}{1} = [xcenter,ycenter,width,height];
end



M = containers.Map(keySet,valueSet);




C1= {'h','e','l','l','o','w','o','r','l','d'};
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



% 
% 
% figure('Position',[100 100 800 800 ])
% grid on
% axis equal
% ax = gca;
% rotate3d on
% view(360, -270)
% axis([-0.5 0.5 -0.5 0.5  -0.5 0.5 ]*5000)
% xlabel('x-axis')
% ylabel('y-axis')
% zlabel('z-axis')
% 
% hold on
% 
% 
% mPosH = plot3(0,0,0,'ko','MarkerFaceColor','r');
% 
% 
% N2 = size(tData1,1);
% 
% L=50;
% index=1;
% 
% 
% 
% mtrace1=zeros(1);
% mtrace2=zeros(1);
% mtrace3=zeros(1);
% 
% for iK = 1:size(keys,1)
%     key = keys(iK);
%     keyPos = key.pos*kbScale;
%     keyPosWorld = [keyPos(1); keyPos(2); 0; 1];
%     plot3(keyPosWorld(1),keyPosWorld(2),keyPosWorld(3),'ro')
%     text(keyPosWorld(1),keyPosWorld(2),keyPosWorld(3),key.label)
% end
% 
% hold on
% 
% 
% N=min([N1 N2]);
% for i = 1:1:N
%     data = tData(2*i);
%     data1 = tData1(i);
%    
%     kbpos=transformationL(data1.kbPos',data1.hmdRot,data1.hmdPos');
%    
%     mvector1=transformation(data.mPos',data.hmdRot,data.hmdPos');
%     mvector=transformationLL(mvector1(1:3),data1.kbRot,kbpos(1:3));
%     mvector=[-mvector(1),mvector(2),mvector(3)]';
% 
%     
%     set(mPosH,'XData',mvector(1),'YData',mvector(2),'ZData',mvector(3)); 
% 
%     
%     mtrace1=[mtrace1,mvector(1)];
%     mtrace2=[mtrace2,mvector(2)];
%     mtrace3=[mtrace3,mvector(3)];
%     plot3(mtrace1(1,2:end),mtrace2(1,2:end),mtrace3(1,2:end))
%     
%     
%     drawnow
%     
%     keypos=cell2mat(M(M2(index)));
% 
%     keypos1=[keypos(1:2)*kbScale,0];
%     
%     if norm(mvector(1:3)-keypos1')<L
%         
%         M2(index)
%         index=index+1;
%         
%     end
% 
%     if index > A1
%             break
%     end
% end
% 
% 
% 














% 
% 
% 
% 
% 
% 
% KEYBOARD 
% 


figure('Position',[100 100 800 800 ])
grid on
axis equal
ax = gca;
rotate3d on
view(360, -270)
axis([-0.5 0.5 -0.5 0.5  -0.5 0.5 ]*500)
xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')

hold on


kbFrameH = plotFrame3([],[0 0 0],[1 0 0 0],[1 0 0 0]);

mPosH = plot3(0,0,0,'ko','MarkerFaceColor','r');
m1PosH = plot3(0,0,0,'ko','MarkerFaceColor','b');
m2PosH = plot3(0,0,0,'ko','MarkerFaceColor','g');


N2 = size(tData1,1);

N=min([N1 N2]);
mtrace1=zeros(1);
mtrace2=zeros(1);
mtrace3=zeros(1);

m1trace1=zeros(1);
m1trace2=zeros(1);
m1trace3=zeros(1);

m2trace1=zeros(1);
m2trace2=zeros(1);
m2trace3=zeros(1);


for iK = 1:size(keys,1)
    key = keys(iK);
    keyPos = key.pos*kbScale;
    keyPosWorld = [keyPos(1); keyPos(2); 0; 1];
    plot3(keyPosWorld(1),keyPosWorld(2),keyPosWorld(3),'ro')
    text(keyPosWorld(1),keyPosWorld(2),keyPosWorld(3),key.label)
end


for i = 1:1:N
    data = tData(2*i);
    data1 = tData1(i);
   
    kbpos=transformationL(data1.kbPos',data1.hmdRot,data1.hmdPos');
   
    mvector1=transformation(data.mPos',data.hmdRot,data.hmdPos');
    mvector=transformationLL(mvector1(1:3),data1.kbRot,kbpos(1:3));
    mvector=[-mvector(1),mvector(2),mvector(3)]';

    
    set(mPosH,'XData',mvector(1),'YData',mvector(2),'ZData',mvector(3)); 
    
    mtrace1=[mtrace1,mvector(1)];
    mtrace2=[mtrace2,mvector(2)];
    mtrace3=[mtrace3,mvector(3)];
    plot3(mtrace1(1,2:end),mtrace2(1,2:end),mtrace3(1,2:end))
    
    m1vector1=transformationL(data1.m1Pos',data1.hmdRot,data1.hmdPos');
    m1vector=transformationLL(m1vector1(1:3),data1.kbRot,kbpos(1:3));
    m1vector=[-m1vector(1),m1vector(2),m1vector(3)]';
%     set(m1PosH,'XData',m1vector(1),'YData',m1vector(2),'ZData',m1vector(3)); 
    
    
    m1trace1=[m1trace1,m1vector(1)];
    m1trace2=[m1trace2,m1vector(2)];
    m1trace3=[m1trace3,m1vector(3)];
%     plot3(m1trace1(1,2:end),m1trace2(1,2:end),m1trace3(1,2:end))
    
    
    
    m2vector1=transformationL(data1.m2Pos',data1.hmdRot,data1.hmdPos');
    m2vector=transformationLL(m2vector1(1:3),data1.kbRot,kbpos(1:3));
    m2vector=[-m2vector(1),m2vector(2),m2vector(3)]';
    set(m2PosH,'XData',m2vector(1),'YData',m2vector(2),'ZData',m2vector(3)); 
    
    m2trace1=[m2trace1,m2vector(1)];
    m2trace2=[m2trace2,m2vector(2)];
    m2trace3=[m2trace3,m2vector(3)];
    plot3(m2trace1(1,2:end),m2trace2(1,2:end),m2trace3(1,2:end))
    
    kbFrameHH= transformationLL(kbpos(1:3),data1.kbRot,kbpos(1:3));
    
    
    kbFrameH = plotFrame3L(kbFrameH,kbFrameHH,data1.kbRot,data1.kbRot);
    
    
    
    
    drawnow
    

end


% HOLOLENS FRAME

% 
% figure('Position',[100 100 800 800 ])
% grid on
% axis equal
% ax = gca;
% rotate3d on
% view(0, 90)
% axis([-0.5 0.5 -0.5 0.5  -0.5 0.5 ]*2)
% xlabel('x-axis')
% ylabel('y-axis')
% zlabel('z-axis')
% % Construct initial handles
% hold on
% % hmdFrame = plotFrame([],[0 0 0],[1 0 0 0]); %why starts from zero
% 
% kbFrameH = plotFrame3([],[0 0 0],[1 0 0 0],[1 0 0 0]);
% 
% mPosH = plot3(0,0,0,'ko','MarkerFaceColor','r');
% m1PosH = plot3(0,0,0,'ko','MarkerFaceColor','r');
% m2PosH = plot3(0,0,0,'ko','MarkerFaceColor','r');
% 
% 
% N2 = size(tData1,1);
% 
% N=min([N1 N2]);
% for i = 1:1:N
%     data = tData(2*i);
%     data1 = tData1(i);
%    
%     mvector=transformation(data.mPos',data.hmdRot,data.hmdPos')*5;
% %     offset=m1vector-mvector;
%     offset=[0.1418 0.6985 -0.5577  0]';
%     mvector=mvector+offset;
%     
%     mvector
%     set(mPosH,'XData',mvector(1),'YData',mvector(2),'ZData',mvector(3)); 
%     
%     
%     m1vector=transformationL(data1.m1Pos',data1.hmdRot,data1.hmdPos');
%     m1vector
%     set(m1PosH,'XData',m1vector(1),'YData',m1vector(2),'ZData',m1vector(3)); 
%     
%     m2vector=transformationL(data1.m2Pos',data1.hmdRot,data1.hmdPos');
%     m2vector
%     set(m2PosH,'XData',m2vector(1),'YData',m2vector(2),'ZData',m2vector(3)); 
%     
%     
%     
%     drawnow
%     
% 
% end







