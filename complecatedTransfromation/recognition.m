  %create a map contrainner for all the keys and the corresponding 3d
  %position 

  keySet = {'a','b','c','d','e',...};
  PosSet = [327.2 368.2 197.6 178.4];
  M = containers.Map(keySet,PosSet);
  
  word = 'hello';
  x1='h';
  x2='e';
  x3='l';
  x4='l';
  x5='o';
  
 
  
  for i = 1:N
      if norm(fingertio(i)-K('x1'))<L
          continue
      end
      
      
      if norm(fingertio(i)-K('x2'))<L
          continue
      end
      
      
       if norm(fingertio(i)-K('x3'))<L
          continue
       end




        if norm(fingertio(i)-K('x4'))<L
          continue
        end



     
        if norm(fingertio(i)-K('x5'))<L
          continue
        end
   
      
        disp(word )
        
  end
  
  
  
  
  
  
  
  
  
  
  
  
          
          
          
          
 
          
          