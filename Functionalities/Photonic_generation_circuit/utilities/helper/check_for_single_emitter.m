function [emitter,emitter_flag_Gate] = check_for_single_emitter(Tab,n,np,Stabrow)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 14, 2024
%--------------------------------------------------------------------------
%
%Function to check if there is a single available emitter for photon 
%absorption w/o needing emitter CNOTs upfront.
%Inputs: Tab: Tableau
%        n: total # of qubits (emitters+photons)
%        np: # of photons
%        Stabrow: stabilizer row to test if the Pauli weight on emitters is 
%                 equal to 1.
%Output: emitter: the index of the emitter qubit if it exists 
%                 (otherwise it is empty)
%        emitter_flag_Gate: the Pauli on the emitter for the stabilizer row

emitter           = [];
emitter_flag_Gate = [];

%-------- Get locs of X, Y, Z on emitters -------------------
S    = Tab(Stabrow,:);
SXem = S(np+1:n);
SZem = S(np+1+n:2*n);

X = SXem>0;
Z = SZem>0; 

Y = X & Z;
X = X & ~Y;
Z = Z & ~Y;

%Check if there is a single true value:

if sum([X,Y,Z])==1
    
    if any(X)
        
        emitter= find(X)+np;
        emitter_flag_Gate='X';
        
    elseif any(Y)

        emitter= find(Y)+np;
        emitter_flag_Gate='Y';
        
    else
       
        emitter= find(Z)+np;
        emitter_flag_Gate='Z';
        
    end
    
else %Verify that there are no qubits in product state:
    
    emitters_in_X = find(X)+np;
    to_remove     = [];
    cnt           = 0;
    
    for k=1:length(emitters_in_X)
       
        cond_prod = qubit_in_product(Tab,n,emitters_in_X(k));
        
        if cond_prod
            
           to_remove=[to_remove,k];
           
        else
            
            cnt=cnt+1;
            
            if cnt>1
                return
            end
            
        end
        
    end
    
    emitters_in_X(to_remove)=[];
    
    emitters_in_Z = find(Z)+np;
    to_remove=[];
    
    for k=1:length(emitters_in_Z)
       
        cond_prod = qubit_in_product(Tab,n,emitters_in_Z(k));
        
        if cond_prod
            
           to_remove=[to_remove,k];
           
        else
            
            cnt=cnt+1;
            
            if cnt>1
               return 
            end
            
        end
        
    end
    
    emitters_in_Z(to_remove)=[];
    
    emitters_in_Y = find(Y)+np;
    to_remove     = [];
    
    for k=1:length(emitters_in_Y)
       
        cond_prod = qubit_in_product(Tab,n,emitters_in_Y(k));
        
        if cond_prod
            to_remove = [to_remove,k];
        else
            
            cnt=cnt+1;
            if cnt>1
                return
            end
            
        end
        
    end
    
    emitters_in_Y(to_remove)=[];
    
    emitter = [emitters_in_X,emitters_in_Y,emitters_in_Z];
    
    if ~isempty(emitters_in_X)
       
        emitter_flag_Gate='X';
        
    elseif ~isempty(emitters_in_Y)
        
        emitter_flag_Gate='Y';
        
    elseif ~isempty(emitters_in_Z)
        
        emitter_flag_Gate='Z';
        
    end
    
end


end
