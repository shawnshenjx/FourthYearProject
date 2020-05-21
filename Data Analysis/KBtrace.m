

clear all
close all

layoutFile = 'holokeyboard.txt';
kbScale = 0.0001;
[keys] = parseLayout(layoutFile);




% filename = 'Trace_data_processed/ID1/final_kbtrace-log_our_fax_number_has_changed_200213_013853.csv';

ID=2;

pat1=sprintf('Trace_data_processed/ID%d',ID);

pat2=sprintf('Trace_data/ID%d/kbtrace',ID);
pat=pat1;
% pat2='Trace_data/ID1/plot_trace/';
fil=fullfile(pat,'*.csv');
d=dir(fil);

number=0
% for k=1:1

%   filename=fullfile(pat,d(k).name)
  filename='Trace_data_processed\ID2\kbtrace-log_i_didnt_think_we_had_200218_013104.csv';
  number=number+1
  fid = fopen(filename);
  
  phrase_split=split(filename,'_');
  phrase_split=phrase_split(5:end-2);
  phrase=join(phrase_split);
    
  
% Data to populate from file
tData = [];

% Read first line of file, discard header
tline = fgetl(fid);


while ischar(tline)
    % Split data row into columns
    if pat==string(sprintf('Trace_data_processed/ID%d',ID))
        cols = str2double(strsplit(tline,' '));
    end
    
    if pat==string(sprintf('Trace_data/ID%d/kbtrace',ID))
        cols = str2double(strsplit(tline,','));
    end
    % Assemble new data structure for sample
    
%     cols = str2double(strsplit(tline,','));
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


figure(11)

% figure('Position',[100 100 800 800 ]);
grid on
axis equal
ax = gca;
rotate3d on
view(45, 45)
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
    plot3(keyPosWorld(1),keyPosWorld(2),keyPosWorld(3),'ro');
    text(-keyPosWorld(1),keyPosWorld(2),keyPosWorld(3),key.label);
end


for i = 1:1:N
    data = tData(i);
    mvector=data.mPos;
    mvector=[mvector(1),mvector(2),mvector(3)];
    
    
    mtrace1=[mtrace1,mvector(1)];
    mtrace2=[mtrace2,mvector(2)];
    mtrace3=[mtrace3,mvector(3)];
    set(mPosH,'XData',mvector(1),'YData',mvector(2),'ZData',mvector(3)); 
%     plot3(mtrace1(1,2:end),mtrace2(1,2:end),mtrace3(1,2:end),'.');
%     drawnow
    

    

end

set(mPosH,'XData',mvector(1),'YData',mvector(2),'ZData',mvector(3)); 
plot3(mtrace1(1,2:end),mtrace2(1,2:end),mtrace3(1,2:end),'.');
% saveas(gcf,sprintf('Trace_data/ID1/kbtrace/%s.png',string(phrase)));

% end
fclose('all');