








clear all

close all

addpath('Functions')


addpath('NEWDATA')
% Open tracking log

layoutFile = 'holokeyboard.txt';
kbScale = 0.1;
[keys] = parseLayout(layoutFile);

filename = 'hello_world_slow_in_kb_frame.csv';
fid = fopen(filename);

% Data to populate from file
tData = [];

% Read first line of file, discard header
tline = fgetl(fid);


while ischar(tline)
    % Split data row into columns
    cols = str2double(strsplit(tline,','));
    
    % Assemble new data structure for sample
    data = struct;
    

    data.mPos = cols(1:3);

    
    tData = [tData; data];
    
    % Get next line
    tline = fgetl(fid);
end

N1 = size(tData,1);




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




C1= {'e','l','l','o','w','o','r','l','d'};
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



figure('Position',[100 100 800 800 ])
grid on
axis equal
ax = gca;
rotate3d on
view(0, 90)
axis([-0.5 0.5 -0.5 0.5  -0.5 0.5 ]*500)
xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')
% Construct initial handles
hold on
% hmdFrame = plotFrame([],[0 0 0],[1 0 0 0]); %why starts from zero

kbFrameH = plotFrame3([],[0 0 0],[1 0 0 0],[1 0 0 0]);

mPosH = plot3(0,0,0,'ko','MarkerFaceColor','r');


N = size(tData,1);

L=20;
index=1;

mtrace1=zeros(1);
mtrace2=zeros(1);
mtrace3=zeros(1);

for iK = 1:size(keys,1)
    key = keys(iK);
    keyPos = key.pos*kbScale;
    keyPosWorld = [keyPos(1); keyPos(2); 0; 1];
    plot3(keyPosWorld(1),keyPosWorld(2),keyPosWorld(3),'ro')
    text(keyPosWorld(1),keyPosWorld(2),keyPosWorld(3),key.label)
end

hold on

for i = 1:1:N
    data = tData(i);

    mvector=data.mPos;
    
    mvector=[-mvector(1),mvector(2),mvector(3)]';

    set(mPosH,'XData',mvector(1),'YData',mvector(2),'ZData',mvector(3)); 

    
    mtrace1=[mtrace1,mvector(1)];
    mtrace2=[mtrace2,mvector(2)];
    mtrace3=[mtrace3,mvector(3)];
    plot3(mtrace1(1,2:end),mtrace2(1,2:end),mtrace3(1,2:end))
    
    
    
    drawnow
    
    keypos=cell2mat(M(M2(index)));
    keypos1=[keypos(1:2)*kbScale,0];
    
    if norm(mvector(1:3)-keypos1')<L
        
        M2(index)
        index=index+1;
        
    end

    if index > A1
            break
    end
end

