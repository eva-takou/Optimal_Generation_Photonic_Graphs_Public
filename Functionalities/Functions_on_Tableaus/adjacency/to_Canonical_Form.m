function Tab=to_Canonical_Form(Tab)
%Function to put the stabilizers in canonical form by using only row
%multiplications and SWAPs.
%If it's not possible to do that, we return the tableau that might be
%partialy in canonical form.

n  = size(Tab,2);
n  = (n-1)/2;
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
       
        Tab = update_Tab_rowsum(Tab,n,locs(jj),qubit);
        
    end
    
    
end

for qubit=1:n %Back-substitution
    
   locs = find(Tab(:,qubit));
   locs(locs==qubit)=[];
   %locs = setxor(locs,qubit); %remove the diagonal position where we want to keep the X
   
   for kk=1:length(locs)
       
       if locs(kk)~=qubit
       
            Tab = update_Tab_rowsum(Tab,n,locs(kk),qubit);
            
       end
       
   end
   
end

Sx = Tab(:,1:n);
if ~all(all(Sx==eye(n,'int8')))
   
    %warning('Multiplication of stabilizers is not enough for canonical form.')
    
end


end