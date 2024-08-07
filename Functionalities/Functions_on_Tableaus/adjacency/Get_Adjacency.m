function [Gamma]=Get_Adjacency(Tab) 
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 25, 2024
%--------------------------------------------------------------------------
%
%Function to obtain the adjacency matrix from a Stabilizer Tableau.
%Input:  Tab: Input stabilizer tableau (n x 2n+1 array)
%Output: Gamma: Adjacency matrix

Tab = Tab(:,1:end-1);  %Drop the phase info.
n   = size(Tab,1);

% Sx = Tab(:,1:n);
% 
% if all(diag(Sx)>0) %faster than all(all(Sx==eye(n,'int8'))) 
%    
%     Gamma = Tab(:,n+1:end);
%     Gamma = Gamma - diag(diag(Gamma));
%     
%     %mustBeValidAdjacency(Gamma)
%     return
%     
% end

for qubit=1:n

    Tq    = Tab(:,qubit);     %Check the columns to see if we have X
    
    if ~any(Tq) %No X, so apply a Hadamard 

       %Apply Hadamard:
       Tq             = Tab(:,qubit+n);  
       Tab(:,qubit+n) = Tab(:,qubit);
       Tab(:,qubit)   = Tq;    
       
    else %If the X is on or after the qubit position, do not apply H gate

        apply_Had=true;
        
        for l=qubit:n

            if Tq(l)==1 

                apply_Had=false;                 

                break

            end

        end

        if apply_Had

           Tq             = Tab(:,qubit+n);  
           Tab(:,qubit+n) = Tab(:,qubit);
           Tab(:,qubit)   = Tq;              
           
        end

    end
    
    if Tq(qubit)~=1 %SWAP rows
        
        indx         = find(Tq);
        jj           = indx(end);
        
        rowToBitXor  = Tab(jj,:);
        Tab(jj,:)    = Tab(qubit,:);
        Tab(qubit,:) = rowToBitXor;

        if length(indx)==1
            continue
        end
        
        L  = length(indx)-1;
        
    else
        
        if sum(Tq)==1
           continue 
        end
        
        indx        = find(Tq);
        rowToBitXor = Tab(qubit,:);
        L           = length(indx);
        
    end
    

    for p=L:-1:1 %start with largest indices
       
        if indx(p)>qubit
            Tab(indx(p),:)=bitxor(Tab(indx(p),:),rowToBitXor);
        else
            break %indices are sorted so we can stop searching
        end

    end
        
    
end


%---Check alternative back-substitution -----------------------------------

Tab=Tab'; %Transpose to access column-wise (maybe slightly faster)

for qubit=n:-1:2
   
    SliceTab    = Tab(qubit,:);
     
    if sum(SliceTab)==1 %Do this to avoid unessecary calls of find
        continue
    end
    
    indx        = find(SliceTab);  %last index is indx==qubit
    L           = length(indx)-1;
    rowToBitXor = Tab(:,qubit);
    
   for k=L:-1:1
          
       Tab(:,indx(k))=bitxor(Tab(:,indx(k)),rowToBitXor);
       
   end    
   
end

%-------- (Alternative Back-substitution w/o transposition) ---------------
% for qubit=n:-1:2
%     
%    SliceTab    = Tab(:,qubit);
%    
%    if sum(SliceTab)==1
%       
%        continue
%        
%    end
%    
%    indx        = find(SliceTab);
%    L           = length(indx)-1;
%    
%    rowToBitXor = Tab(qubit,:);
%    
%    for k=L:-1:1
% 
%        Tab(indx(k),:)=bitxor(Tab(indx(k),:),rowToBitXor);
%        
%    end
%    
% end
%--------------------------------------------------------------------------

%------------------ Remove self-loops -------------------------------------

%Gamma = Tab(:,n+1:end); %w/o transposition do this
Gamma = Tab(n+1:end,:);
Gamma = Gamma - diag(diag(Gamma));
Gamma = single(Gamma);





%---------- Uncomment for error-check: ------------------------------------
% Sx    = Tab(:,1:n);
% 
% if ~all(diag(Sx)>0) %~all(all(eye(n,'int8')==Sx))
%     error('At the end of Gauss elimination, the Sx part of the Tableau is not identity')
% end
%
%
%mustBeValidAdjacency(Gamma)

end