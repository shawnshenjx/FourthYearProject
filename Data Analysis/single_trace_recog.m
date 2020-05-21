clear all
close all


L=0.05;
complete_list_list=[];

lower=0.04;
step=0.005;
upper=0.05;


for L=lower:step:upper
complete_list=[];
    filename='Trace_data/ID1/kbtrace/kbtrace-log_please_call_tomorrow_if_possible_200213_015530.csv';

    load('M.mat')

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
        if isempty(tline)
            break
        end
    
    end

    N = size(tData,1);


    phrase_split=split(filename,'_');
    phrase_split=phrase_split(3:end-2);
    splitmessage=split(replace(join(phrase_split),' ','_'),'');

    splitmessage(1)=cellstr('d');
    splitmessage(end)=cellstr('d');
    C1= transpose(splitmessage(1:end));



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

        if index > len
            index=len;
        end
      

        key_=M2(index);
        keypos=cell2mat(M(key_));

        keypos1=[keypos(1:2)*kbScale,0];

        a=keypos1(1);
        b=keypos1(2);
        c=keypos1(3);
        keypos2=transpose([-a ,b,c]);
        pos_d=transpose([pos(1),pos(2),pos(3)]);

        pos=transpose([pos(1),pos(2),0]);

        down_key=transpose([0,-0.1,-0.1]);

        if or(and(index==1,norm(pos_d-down_key)<L_d),and(index==A1,norm(pos_d-down_key)<L_d))
            letter=M2(index);
            letter_list=append(letter_list,string(letter));
            index=index+1 ;
        else
            letter =[''];
        end






        if norm(pos-keypos2) <L && index<A1 && abs(pos_d(3))<L_v
            letter=M2(index)
            letter_list=append(letter_list,string(letter));
            index=index+1;
        else
            letter =[''];
        end




    end
    letter_list=split(letter_list,'');
    letter_list_true_=split(cell2mat(C1),'');
    letter_list_true=letter_list_true_(3:end-2);
    replace(replace(join(letter_list_true),' ',''),'_',' ')
    len1=size(letter_list_true);
    len_true=len1(1);
        
    
    letter_list_now2=replace(replace(join(letter_list(3:end-2)),' ',''),'_',' ')
    len=strlength(letter_list_now2);
    
    complete=len/len_true
    complete_list=cat(1,complete_list,complete);
%     if complete~=1
%         filename
%         delete(filename)
%     end
        
%     if complete==1
%         complete_list=cat(1,complete_list,complete);
%     end 
    


% 
% complete_list_list=cat(2,complete_list_list,complete_list);
% size(find(complete_list==1))==size(complete_list);

end
% 
% 
% %plot the number of correct phrases in each tolerence length 
% figure(1)
% num_2=[];
% L_list=[];
% for L=lower:step:upper
%     L_list=cat(1,L_list,L);
% end
% 
% for i = 1:size(L_list,1)
%     num_1=size(find(complete_list_list(:,i)==1));
%     num_2=cat(1,num_2,num_1(1));
%     
% 
% end
% 
% plot(L_list,num_2,'-o')
% ylabel('number of correct phrases')
% xlabel('tolerent length')
% 
% 
% 
% %plot the average correctness in each tolrence length
% 
% figure(2)
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
%     correctness_2=cat(1,correctness_2,correctness_1);
%     
% end
% 
% plot(L_list,correctness_2,'-o')
% ylabel('average correctness')
% xlabel('tolerent length')
% 
% 
% 
% %plot the correctness in each tolerence length 
