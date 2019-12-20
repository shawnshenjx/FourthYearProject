


addpath('kb_trace')

layoutFile = 'holokeyboard.txt';
kbScale = 0.0001;
[keys] = parseLayout(layoutFile);

filename = 'kbtrace-log_they_are_more_efficiently_pooled_191220_041052.csv';
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




figure('Position',[100 100 800 800 ])
grid on
axis equal
ax = gca;
rotate3d on
view(360, -270)
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


for i = 1:1:N
    data = tData(i);
    mvector=data.mPos;
    mvector=[mvector(1),mvector(2),mvector(3)];
    set(mPosH,'XData',mvector(1),'YData',mvector(2),'ZData',mvector(3)); 
    mvector
    mtrace1=[mtrace1,mvector(1)];
    mtrace2=[mtrace2,mvector(2)];
    mtrace3=[mtrace3,mvector(3)];
    plot3(mtrace1(1,2:end),mtrace2(1,2:end),mtrace3(1,2:end),'.')

    
    drawnow
    

    

end

