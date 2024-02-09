function Tab=Back_Subs_On_RREF_Tab(Tab,n,Insert_Rows)
%Function to the matrix into RREF: include also back-substitution
%Input: Tab:Tableau
%       n: # of qubits
%       Insert_Rows: If empty we perform the back-substitution on the entire
%       thing. If non-empty we perform back-substitution till the specified
%       row.
%                     
%Output: The updated Tableau.


%Do back-substitution
%Check the weigth of Row_j and Row_k with j<k.
%If multiplication with Row_k reduces the length of Row_j then perform the
%multiplication.

if isempty(Insert_Rows)
   
    exit_row = 1;
    
else
    
    exit_row = Insert_Rows;
    
end


Rowk = n;

while true

    for jj=Rowk-1:-1:1   

        StabRow  = Tab(jj,:); 
        SX = StabRow(1:n);
        SZ = StabRow(n+1:2*n);
        
        weight_before = sum(SX+SZ)-sum(bitand(SX,SZ));
        
        if weight_before>1

            newRow = bitxor(StabRow,Tab(Rowk,:));
            SX = newRow(1:n);
            SZ = newRow(n+1:2*n);

            weight_after = sum(SX+SZ)-sum(bitand(SX,SZ));
            
            if weight_after<weight_before

                Tab = rowsum(Tab,n,jj,Rowk);

            end                

        end
        
    end

    Rowk = Rowk-1;

    if Rowk==exit_row

        break

    end




end



end


