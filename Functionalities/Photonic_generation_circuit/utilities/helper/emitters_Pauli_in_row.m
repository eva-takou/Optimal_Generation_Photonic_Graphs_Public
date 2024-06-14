function [emitters_in_X,emitters_in_Y,emitters_in_Z]=emitters_Pauli_in_row(Tab,Stabrow,np,ne) 
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 14, 2024
%--------------------------------------------------------------------------
%
%Get the emitters Pauli for a particular stabilizer row, excluding emitters
%in product state.
%
%Inputs: Tab: Tableau
%        Stabrow: The stabilizer row to get the emitters
%        np: # of photons
%        ne: # of emitters
%Output: the indices of emitters in X, in Y and in Z, counting from np+1:n.

n = np+ne;

S    = Tab(Stabrow,:);
SXem = S(np+1:n);
SZem = S(np+1+n:2*n);

X = SXem==1; %Logical indices
Z = SZem==1; 

Y = X & Z;
X = X & ~Y;
Z = Z & ~Y;

emitters_in_X  = find(X)+np;
emitters_in_Y  = find(Y)+np;
emitters_in_Z  = find(Z)+np;

%Should remove the emitters in product state:

to_remove=[];
for k=1:length(emitters_in_X)
   
    cond_prod=qubit_in_product(Tab,n,emitters_in_X(k));
    
    if cond_prod
        to_remove=[to_remove,k];
       
    end
    
end

emitters_in_X(to_remove)=[];

to_remove=[];
for k=1:length(emitters_in_Y)
   
    cond_prod = qubit_in_product(Tab,n,emitters_in_Y(k));
    
    if cond_prod
        to_remove=[to_remove,k];
       
    end
    
end

emitters_in_Y(to_remove)=[];

to_remove=[];
for k=1:length(emitters_in_Z)
   
    cond_prod=qubit_in_product(Tab,n,emitters_in_Z(k));
    
    if cond_prod
        to_remove=[to_remove,k];
       
    end
    
end

emitters_in_Z(to_remove)=[];
end