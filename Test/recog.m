
close all
clear all
layoutFile = 'holokeyboard.txt';
kbScale = 0.0001;
[keys] = parseLayout(layoutFile);

filename = 'kbtrace-log_is_she_done_yet_191218_071541.csv';
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
    data.t = cols(4);
    
    % Append sample
    tData = [tData; data];
    
    % Get next line
    tline = fgetl(fid);
end

N = size(tData,1);


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


L=0.06;



figure('Position',[100 100 800 800 ])
grid on
axis equal
ax = gca;
rotate3d on
view(20, 45)
axis([-0.5 0.5 -0.5 0.5  -0.5 0.5 ])
xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')

hold on
mtrace1=zeros(1);
mtrace2=zeros(1);
mtrace3=zeros(1);

mPosH = plot3(0,0,0,'ko','MarkerFaceColor','r');


for iK = 1:size(keys,1)
    key = keys(iK);
    keyPos = key.pos*kbScale;
    keyPosWorld = [keyPos(1); keyPos(2); 0; 1];
    plot3(keyPosWorld(1),keyPosWorld(2),keyPosWorld(3),'ro')
    text(-keyPosWorld(1),keyPosWorld(2),keyPosWorld(3),key.label)
end

index=1;


for i = 1:1:N
    data = tData(i);
    mvector=data.mPos;
    
    set(mPosH,'XData',mvector(1),'YData',mvector(2),'ZData',mvector(3)); 
    
    mtrace1=[mtrace1,mvector(1)];
    mtrace2=[mtrace2,mvector(2)];
    mtrace3=[mtrace3,mvector(3)];
    plot3(mtrace1(1,2:end),mtrace2(1,2:end),mtrace3(1,2:end),'.')
%     
%     [index, letter] = recognition(mvector,index);
%     index;
%     letter
%     
    pos=mvector;



    keypos=cell2mat(M(M2(index)));

    keypos1=[keypos(1:2)*kbScale,0];


    a=keypos1(1);
    b=keypos1(2);
    c=keypos1(3);
    keypos2=transpose([-a ,b,c]);
    pos=transpose([pos(1),pos(2),pos(3)]);

    if norm(pos-keypos2) <L
        letter=M2(index)
        index=index+1 ;
    else
        letter =[' '];
    end
    drawnow
    

    

end
% 
% 
% 
% index=9;
% L=0.1;
% for i = 1:1:N
%     data = tData(i);
%     mvector=data.mPos;
%     
%     keypos=cell2mat(M(M2(index)));
% 
%     keypos1=[keypos(1:2)*kbScale,0];
% 
% 
%     a=keypos1(1);
%     b=keypos1(2);
%     keypos2=transpose([-a ,b]);
%     
%     if norm(mvector-keypos2) <L
%         letter=M2(index)
%     end
% 
% 
%     
% 
% end




% 
% 
% function [index, letter] = recognition(pos,index)
% 
% 
% 
% fileID = fopen('holokeyboard.txt','r');
% 
% C = textscan(fileID,'%s %f %f %f %f','Delimiter',';');
% 
% A=size(C{1});
% keySet=strings(1,A(1));
% 
% 
% keySet(1)=C{1}{1};
% valueSet=cell(1,A(1));
% 
% xcenter=C{2}(1);
% ycenter=C{3}(1);
% width=C{4}(1);
% height=C{5}(1);
% 
% valueSet{1}{1} = [xcenter,ycenter,width,height];
% for i = 2:1:A(1)
%     keySet(i)=C{1}{i};
%     xcenter=C{2}(i);
%     ycenter=C{3}(i);
%     width=C{4}(i);
%     height=C{5}(i);
%     
%     valueSet{i}{1} = [xcenter,ycenter,width,height];
% end
% 
% 
% 
% M = containers.Map(keySet,valueSet);
% 
% 
% 
% 
% C1= {'h','e','l','l','o','w','o','r','l','d'};
% A1=size(C1);
% A1=A1(2);
% keySet1=strings(1,A1);
% 
% valueSet1=zeros(1,A1);
% for i = 1:1:A1
%     keySet1(i)=C1(i);
%     valueSet1(i) = i;
% end
% M2  = containers.Map(valueSet1,keySet1);
% M3  = containers.Map(keySet1,valueSet1);
% 
% 
% L=0.1;
% 
% kbScale=0.0001;
% 
% keypos=cell2mat(M(M2(index)));
%  
% keypos1=[keypos(1:2)*kbScale,0];
% 
% 
% a=keypos1(1);
% b=keypos1(2);
% keypos2=transpose([-a ,b]);
% 
% if norm(pos-keypos2) <L
%         letter=M2(index);
% 		index=index+1 ;
% else
%         letter =[' '];
% end
% 
% 
% end
% 

