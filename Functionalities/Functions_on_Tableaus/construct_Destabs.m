function D=construct_Destabs(S)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 2, 2024
%--------------------------------------------------------------------------
%
%Function to generate the destabilizer group. The input stabilizer Tableau
%should be in Canonical form.
%Input:  S: The n x 2n int8 stabilizer   array with binary entries
%Output: D: The n x 2n int8 destabilizer array with binary entries

[n,~]=size(S);

Sx = S(:,1:n); Sz = S(:,n+1:2*n);  D = zeros(n,2*n,'int8');

for ii=1:n


    if Sx(ii,:)==1 %X_i

        TEMP          = zeros(n,2*n,'int8');
        TEMP(ii,ii+n) = 1; %Make a Z_i destabilizer
        
        D = D + TEMP; 

    elseif Sz(ii,:)==1 %Z_i

        TEMP = zeros(n,2*n,'int8'); %Make a X_i destabilizer
        TEMP(ii,ii)=1;
        
        D = D + TEMP; 
        
    end


end


end
