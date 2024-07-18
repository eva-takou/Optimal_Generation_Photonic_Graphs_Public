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
        
        for jj=qubit+1:n

            if Tq(jj)==1 

                temp         = Tab(jj,:);
                Tab(jj,:)    = Tab(qubit,:);
                Tab(qubit,:) = temp;
                Tq(jj)       = 0;
                
                break

            end

        end
    
    end
    
    locs = Tq(qubit+1:n)>0;
    
    if sum(locs)==0 %~any(locs) %Do this to avoid unessecary calls of find
        continue
    end
    
    indx        = find(locs)+qubit;
    rowToBitXor = Tab(qubit,:);
    
    for p=1:length(indx)
       
        Tab(indx(p),:)=bitxor(Tab(indx(p),:),rowToBitXor);
        
    end
        
end


%---Check alternative back-substitution -----------------------------------

Tab=Tab'; %Transpose to access column-wise (maybe slightly faster)

for qubit=n:-1:2
   
    SliceTab    = Tab(qubit,:)>0;
     
    if sum(SliceTab)==1 %Do this to avoid unessecary calls of find
        continue
    end
    
    
    indx        = find(SliceTab(1:qubit-1));
    rowToBitXor = Tab(:,qubit);
    
   for k=length(indx):-1:1
      
       Tab(:,indx(k))=bitxor(Tab(:,indx(k)),rowToBitXor);
       
   end    
    
end

%-------- (Alternative Back-substitution w/o transposition) ---------------
% for qubit=n:-1:2
%     
%    SliceTab    = Tab(:,qubit)>0; 
%    rowToBitXor = Tab(qubit,:);
%    
%    for k=qubit-1:-1:1
%        
%        if SliceTab(k)
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