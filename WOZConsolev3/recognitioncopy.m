function [index, letter] = recognitioncopy(pos,index,messageString)


load('M.mat')


splitmessage=split(messageString,['']);
C1= transpose(splitmessage(2:end-1));
%C1={'h','o'};
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


L=0.005;

kbScale=0.0001;

keypos=cell2mat(M(M2(index)));
 
keypos1=[keypos(1:2)*kbScale,0];

a=keypos1(1);
b=keypos1(2);
c=keypos1(3);
keypos2=transpose([-a ,b,c]);
pos=transpose([pos(1),pos(2),pos(3)]);


if norm(pos-keypos2) <L
        letter=M2(index);
		index=index+1 ;
else
        letter =[''];
end

end


