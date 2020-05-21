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

fclose(fid)


figure;

for ID = 1:2:20

pat1=sprintf('Trace_data_processed/ID%d',ID);

pat2=sprintf('Trace_data/ID%d/kbtrace',ID);
pat=pat1;

fil=fullfile(pat,'*.csv');
d=dir(fil);
L=0.05;
complete_list_list=[];

lower=0.01;
step=0.005;
upper=0.05;


TData=[];

index_list_all=[];

    
for L=lower:step:upper
complete_list=[];
for k=1:numel(d)
  filename=fullfile(pat,d(k).name);
  filename
  



    load('M.mat')

    fid = fopen(filename);

    % Data to populate from file
    tData = [];

    % Read first line of file, discard header
    tline = fgetl(fid);



    while ischar(tline)
        % Split data row into columns
        
        cols = str2double(strsplit(tline,' '));
        

        
      
        
%         cols = str2double(strsplit(tline,','));
       

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

    for i = 1:1:N
        data = tData(i);
        pos=data.mPos;
        
        
        len=size(keySet1);
        len=len(2);

%         if index > len
%             index=len;
%         end
      

        key_=M2(index);
        keypos=cell2mat(M(key_));

        keypos1=[keypos(1:2)*kbScale,0];

        a=keypos1(1);
        b=keypos1(2);
        c=keypos1(3);
        keypos2=transpose([-a ,b,c]);
        pos_d=transpose([pos(1),pos(2),pos(3)]);

        pos=transpose([pos(1),pos(2),0]);
        


        if norm(pos-keypos2) <L && index<=A1 && abs(pos_d(3))<L_v
            
            letter=M2(index);
            letter_list=append(letter_list,string(letter));
            index=index+1;
            
        end
%         
        if index==A1+1
            break
        end

    end
    letter_list=split(letter_list,'');
    letter_list_true_=split(cell2mat(C1),'');
    letter_list_true=letter_list_true_(2:end-1);
%     replace(replace(join(letter_list_true),' ',''),'_',' ');
    len1=size(letter_list_true);
    len_true=len1(1);
        
    
    letter_list_now2=replace(replace(join(letter_list(2:end)),' ',''),'_',' ')
    len=strlength(letter_list_now2);
    
    complete=len/len_true
    if isnan(complete)
        complete=0;
    end
    
    phrase_split=split(filename,'_');
    phrase_split=phrase_split(4:end-2);    
    letter_list_=string(replace(join(phrase_split),' ','_'));
    if complete == 1 && sum(ismember(index_list_all,find(phrase_list==letter_list_)))==0
        

        index_list_all=[index_list_all,find(phrase_list==letter_list_)];


        data=struct;
        data.index_list=find(phrase_list==letter_list_);

        data.accuracy=L;
        TData = [TData; data];
    end
    
    complete_list=cat(1,complete_list,complete);

    
fclose('all')

end
complete_list_list=cat(2,complete_list_list,complete_list);
size(find(complete_list==1))==size(complete_list);

end





TDATA=[];
for i =1:1:1050
for j = 1:1:size(TData,1)
%     tData(j).index_list
    
    if TData(j).index_list==i
        i;
        Data=struct;
        
        
        Data.index=TData(j).index_list;
        
        Data.accuracy=TData(j).accuracy;
       
        TDATA=[TDATA,Data];
    end
end
end


accuracy_list=[];


for i =1:1:size(TDATA,2)
    
    Data=TDATA(i);
    accuracy_list=[accuracy_list,Data.accuracy];


end


num_list=1:1:size(TDATA,2);
scatter(num_list,accuracy_list,'filled')

hold on



end



% 
% 
% %plot the number of correct phrases in each tolerence length 
% figure(3)
% num_2=[];
% L_list=[];
% for L=lower:step:upper
%     L_list=cat(1,L_list,L);
% end
% 
% for i = 1:size(L_list,1)
%     num_1=size(find(complete_list_list(:,i)==1));
%     num_2=cat(1,num_2,numel(d)-num_1(1));
%     
% 
% end
% 
% plot(L_list,num_2,'-o')
% ylabel('number of incorrect phrases')
% xlabel('tolerent length')
% 
% 
% 
% %plot the average correctness in each tolrence length
% 
% figure(4)
% correctness_2=[];
% 
% L_list=[];
% for L=lower:step:upper
%     L_list=cat(1,L_list,L);
% end
% 
% 
% for i = 1:size(L_list,1)
%     correctness_1=mean(complete_list_list(:,i));
%     correctness_2=cat(1,correctness_2,1-correctness_1);
%     
% end
% 
% plot(L_list,correctness_2,'-o')
% ylabel('average incorrectness')
% xlabel('tolerent length')
% 
% fclose('all');
% 
% %plot the correctness in each tolerence length 
