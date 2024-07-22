function [Tab]=Back_Subs_On_RREF_Tab(Tab,n,Insert_Rows)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 2, 2024
%--------------------------------------------------------------------------
%
%Function to apply back-substitution on a matrix that is in RREF.
%
%Input: Tab:Tableau
%       n: # of qubits
%       Insert_Rows: If empty we perform the back-substitution on the entire
%       matrix. If non-empty we perform back-substitution till the specified
%       row.
%                     
%Output: The updated Tableau.
%
%Do back-substitution
%Check the weigth of Row_j and Row_k with j<k.
%If multiplication with Row_k reduces the length of Row_j then perform the
%multiplication.

if isempty(Insert_Rows)
   
    exit_row   = 1;

else
    
    exit_row   = Insert_Rows;
    
end

% Tab0=Tab;

% Rowk = n;
% 
% 
% while true
% 
%     for jj=Rowk-1:-1:1   
% 
%         StabRow  = Tab(jj,:);                 
%         SX       = StabRow(1:n);
%         SZ       = StabRow(n+1:end-1);
%         
%         weight_before = sum(SX)+sum(SZ)-sum(bitand(SX,SZ));
%         
%         if weight_before>1
% 
%             newRow = bitxor(StabRow,Tab(Rowk,:));
%             SX     = newRow(1:n);
%             SZ     = newRow(n+1:end-1);
%             
%             weight_after = sum(SX)+sum(SZ)-sum(bitand(SX,SZ));
%             
%             if weight_after<=weight_before %weight_after<weight_before
% 
%                 Tab = rowsum(Tab,n,jj,Rowk);
%                 
%             end                
%             
%         end
%         
%     end
% 
%     Rowk = Rowk-1;
% 
%     if Rowk==exit_row
% 
%         break
% 
%     end
% 
% end


Rowk = n;


while true

    SSX  = Tab(:,1:n);
    SSZ  = Tab(:,n+1:2*n);
    
    SSX_k = SSX(Rowk,:);
    SSZ_k = SSZ(Rowk,:);
    
    for jj=Rowk-1:-1:1   

        SX = SSX(jj,:);
        SZ = SSZ(jj,:);
        
        weight_before = sum(SX)+sum(SZ)-sum(bitand(SX,SZ));
        
        if weight_before>1

            SX = bitxor(SX,SSX_k);
            SZ = bitxor(SZ,SSZ_k);
            
            weight_after = sum(SX)+sum(SZ)-sum(bitand(SX,SZ));
            
            if weight_after<=weight_before %weight_after<weight_before

                Tab = rowsum(Tab,n,jj,Rowk);
                
            end                
            
        end
        
    end

    Rowk = Rowk-1;

    if Rowk==exit_row

        break

    end

end


% if ~all(all(Tab==Tab0))
%    error('The two methods do not match.') 
% end


end


