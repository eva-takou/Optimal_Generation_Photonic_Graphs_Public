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
        StabRowX = StabRow(1:n);
        StabRowZ = StabRow(n+1:2*n);

        if sum(StabRowX)==0

            %There are only Zs and no Ys or Xs
            weight_before = sum(StabRowZ);

        elseif sum(StabRowZ)==0

            %There are only Xs and no Ys
            weight_before = sum(StabRowX);

        else

            Xpos = StabRowX>0;
            Zpos = StabRowZ>0;

            count_X_before = (  Xpos  &  ~Zpos);
            count_Z_before = ( ~Xpos  &   Zpos);
            count_Y_before = (  Xpos  &   Zpos);
            weight_before  = sum([count_X_before,count_Z_before,count_Y_before]);

        end

        if weight_before>1

            newRow   = bitxor(StabRow,Tab(Rowk,:));
            StabRowX = newRow(1:n);
            StabRowZ = newRow(n+1:2*n);

            cond_enter=true;

            if sum(StabRowX)==0

                if sum(StabRowZ)>=weight_before
                   cond_enter=false; 

                end

            elseif sum(StabRowZ)==0


                if sum(StabRowX)>=weight_before
                    cond_enter=false; 
                end

            else

                Xpos  = StabRowX>0;
                Zpos  = StabRowZ>0;

                count_X_after = (  Xpos & ~Zpos);
                CNT = sum(count_X_after);

                if CNT>=weight_before

                    cond_enter=false;

                else


                    count_Y_after = ( Xpos & Zpos );

                    CNT = CNT+sum(count_Y_after);

                    if CNT>=weight_before
                       cond_enter=false;

                    else

                        count_Z_after = (~Xpos &  Zpos);

                       CNT = CNT+sum(count_Z_after);

                       if CNT>=weight_before
                           cond_enter=false;
                       end


                    end



                end


            end


            if cond_enter %weight_after<weight_before

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


