function [Gamma]=Get_Adjacency(Tab) 
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 25, 2024
%--------------------------------------------------------------------------
%
%Function to obtain the adjacency matrix from a Stabilizer Tableau.
%Input:  Tab: Input stabilizer tableau (n x 2n+1 array)
%        option: true or false, to store or not the operations that transform
%        the Tableau in canonical form.
%Output: Gamma: Adjacency matrix

Tab(:,end)=[]; %Drop the phase info.
n  = size(Tab,1);
Sx = Tab(:,1:n);


if all(diag(Sx)>0) %faster than all(all(Sx==eye(n,'int8'))) 
   
    Gamma = Tab(:,n+1:end);
    Gamma = Gamma - diag(diag(Gamma));
    
    %mustBeValidAdjacency(Gamma)
    return
    
end


for qubit=1:n

    Tq    = Tab(:,qubit);     %Check the columns to see if we have X
    locs  = Tq>0;
    %locs  = Tq(qubit:end)>0;   %Alternatively

    if ~any(locs) %isempty(locs)  || isempty(locs(locs>=qubit)) %If there is no X, do a Had

       %Apply Hadamard:
       temp           = Tab(:,qubit+n); 
       Tab(:,qubit+n) = Tab(:,qubit);
       Tab(:,qubit)   = temp;    

    else %If the X is on or after the diagonal qubit position, do not apply H gate

        apply_Had=true;

        for l=qubit:n

            if Tq(l)>0

                apply_Had=false;                 

                break

            end

        end

        if apply_Had

           temp           = Tab(:,qubit+n); 
           Tab(:,qubit+n) = Tab(:,qubit);
           Tab(:,qubit)   = temp;  

        end

    end


    if Tab(qubit,qubit)~=1

        SliceTab = Tab(:,qubit);

        for jj=qubit+1:n

            if SliceTab(jj)==1  %SWAP rows

                temp         = Tab(jj,:);
                Tab(jj,:)    = Tab(qubit,:);
                Tab(qubit,:) = temp;

                break

            end

        end

    end

    SliceTab    = Tab(:,qubit);
    rowToBitXor = Tab(qubit,:); 
    indx        = find(SliceTab(qubit+1:end))+qubit; 
    
    for k=1:length(indx) %Remove Xs appearing below the diagonal entry

        Tab(indx(k),:)=bitxor(Tab(indx(k),:),rowToBitXor);

    end

end


%---Check alternative back-substitution -----------------------------------

Tab=Tab'; %Transpose to access column-wise (maybe slightly faster)

for qubit=n:-1:2
   
    SliceTab = Tab(qubit,:);
    rowToBitXor = Tab(:,qubit);
    
    indx = find(SliceTab(1:qubit-1));
    
   for k=length(indx):-1:1
      
       Tab(:,indx(k))=bitxor(Tab(:,indx(k)),rowToBitXor);
       
   end    
    
end

Tab=Tab'; %Revert back

%-------- (Alternative Back-substitution w/o transposition) ---------------


% for qubit=n:-1:2
%     
%    SliceTab    = Tab(:,qubit); 
%    locs        = SliceTab>0;
%    rowToBitXor = Tab(qubit,:);
%    
%    indx = find(SliceTab(1:qubit-1));
%    
%    for k=length(indx):-1:1
%       
%        Tab(indx(k),:)=bitxor(Tab(indx(k),:),rowToBitXor);
%        
%    end
%    
%    for k=qubit-1:-1:1
%        
%        if locs(k) %SliceTab(k)>0 %Tab(k,qubit)==1 
%            
%            Tab(k,:)=bitxor(Tab(k,:),rowToBitXor);
%            
%        end
%        
%    end
%    
% end
%--------------------------------------------------------------------------

%------------------ Remove self-loops -------------------------------------

Gamma = Tab(:,n+1:2*n);
Gamma = Gamma - diag(diag(Gamma));

%---------- Uncomment for error-check: ------------------------------------
% Sx    = Tab(:,1:n);
% 
% if ~all(diag(Sx)>0) %~all(all(eye(n,'int8')==Sx))
%     error('At the end of Gauss elimination, the Sx part of the Tableau is not identity')
% end
%
%
%mustBeValidAdjacency(Gamma)
%--------------------------------------------------------------------------
Gamma=single(Gamma);

end