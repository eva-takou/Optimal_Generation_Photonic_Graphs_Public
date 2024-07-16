function Tab=to_Canonical_Form(Tab)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 25, 2024
%--------------------------------------------------------------------------
%
%Function to put the stabilizers in canonical form by using only row
%multiplications and row SWAPs.
%If it's not possible to do that, we return the tableau modified based on
%row SWAPS and row multiplications.
%
%Input: Tab: Stabilizer tableau (array n x 2n+1)
%Output: Tab: The update stabilizer tableau

n  = size(Tab,1);
Sx = Tab(:,1:n);

if all(all(Sx==eye(n,'int8')))
    
    return
    
end


for qubit=1:n
    
    locs  = find(Tab(:,qubit)); %Check the columns to see if we have X (or Y)
    locs  = locs(locs>=qubit);
    
    if ~isempty(locs) && locs(1)~=qubit %SWAP stabs 
        
        Tab = SWAP_rows(Tab,qubit,locs(1));
        
    end
    
    locs = find(Tab(:,qubit));
    locs = locs(locs>qubit);
    
    for jj=1:length(locs) %Remove Xs appearing below the diagonal entry
       
        Tab = rowsum(Tab,n,locs(jj),qubit);
        
    end
    
    
end

for qubit=1:n %Back-substitution
    
   locs = find(Tab(:,qubit));
   locs(locs==qubit)=[];
   
   for kk=1:length(locs)
       
       if locs(kk)~=qubit
       
            Tab = rowsum(Tab,n,locs(kk),qubit);
            
       end
       
   end
   
end

end