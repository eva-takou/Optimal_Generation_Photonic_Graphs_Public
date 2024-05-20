function mustBeStabGroup(S)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 20, 2024
%
%Throw an error if the input matrix is not sparse
%Input: S: Stabilizer array n x 2n (w/o the phase vector)

mustBeAbelian(S)
mustBeBinary(S)

[n,~]=size(S);

for ii=1:n
    
    for jj=ii+1:n
        
        if all(S(ii,:)==S(jj,:))
            
            ME = MException('mustBeStabGroup:inputError','Detected duplicate operators.');
            throw(ME)            
            
        end
        
    end
    
    if nnz(S(ii,:))==0 %all 0s -> Identity
       
        ME = MException('mustBeStabGroup:inputError','Detected identity as generator.');
        throw(ME)            
        
    end
    
end


end