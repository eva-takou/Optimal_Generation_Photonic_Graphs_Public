function mustBeValidTableau(Tableau)

[n,~] = size(Tableau);
n     = (n-1)/2;
D     = Tableau(1:n,1:2*n);
S     = Tableau(n+1:2*n,1:2*n);

%Check that each one is a valid Abelian group, doesnt include identity, is
%binary.

mustBeStabGroup(D) 
mustBeStabGroup(S) 

PZ2 = [zeros(n,n,'int8') eye(n,'int8') ;...
       eye(n,'int8')  zeros(n,n,'int8')];
   
for ii=1:n
    
    if all(all(mod(mult_int8(mult_int8(D(ii,:),PZ2),S(ii,:).'),2)==zeros(n,n,'int8')))

              
        ME=MException('mustBeStabGroup:inputError',...
                   'Detected destabilizer that doesnt anti-commute with respective stabilizer.');
        
        throw(ME)
    end
    
    
    for jj=1:n
   
        if jj~=ii
            
           
           if any(mod(mult_int8(mult_int8(D(ii,:),PZ2),S(jj,:).'),2)~=zeros(n,n,'int8'))
              
               ME=MException('mustBeStabGroup:inputError',...
                   'Detected destabilizer (j) that doesnt commute with other(s) stabilizer (\neq j).');
               
               throw(ME)
               
               
           end
            
            
            
        end
        
        
    end
    
    
    
end








end