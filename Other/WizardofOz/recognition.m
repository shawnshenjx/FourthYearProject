function [index, letter] = recognition(pos,index)



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


L=100;


keypos=cell2mat(M(M2(index)));
 
keypos1=[keypos(1:2)*kbScale,0];

keypos2=transpose(keypos1);

if norm(pos-keypos2) <L
		index=index+1;   
end

letter=M2(index-1);