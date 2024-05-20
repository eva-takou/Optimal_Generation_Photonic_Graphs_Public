function mustBeAbelian(S)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%
%Test if the input stabilizer array is abelian (commutative).
%
%Input: S: Stabilizer array nx2n (SX|SZ) (w/o the phases)

[n,N] = size(S);

if N~=2*n
   
    error('The input array in mustBeAbelian is not n x 2n.') 
    
end

PZ2 = [zeros(n,n,'int8') , eye(n,'int8') ; ...
       eye(n,'int8')    , zeros(n,n,'int8') ];

if any(mod(double(S)*double(PZ2)*double(S.'),2)~=zeros(n,n,'int8'))
    
     ME = MException('mustBeAbelian:inputError','Input set is not Abelian');
    
     throw(ME)
    
end

end