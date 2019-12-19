function [index, letter] = recognitioncopy(pos,index,messageString)


load('M.mat')

%messageString= messageString(find(~isspace(messageString)));
messageString=replace(messageString," ","");
splitmessage=split(messageString,['']);
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


L=0.031;
L_d=0.05;
kbScale=0.0001;


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
		index=index+1 ;
else
		letter =[''];
end



if and(norm(pos-keypos2) <L,index<A1)
		letter=M2(index);
		index=index+1 ;
else
		letter =[''];
end


end


