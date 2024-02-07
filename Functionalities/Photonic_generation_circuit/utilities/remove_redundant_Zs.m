function [Tab,Circuit]=remove_redundant_Zs(Tab,np,ne,Circuit,Store_Gates)
%Function to bring all emitters in Z/to row-multiply to remove trivial Z
%operators.
%Inputs: Tab: Tableau
%        np: # of photons
%        ne: # of emitters
%        Circuit: The circuit so far
%Output: Tab: The updated tableau
%        Circuit: The updated circuit

n = np+ne;

%Make sure that all qubits are in product:

for qubit = 1:n
    
   [cond_product, state_flag]= qubit_in_product(Tab,n,qubit); 
    
   if ~cond_product
       
      ME=exception('MyComponent:falseCond','Some qubit was not in product state');
      throw(ME)
       
   else
       
       %Bring all the qubits into Zs:
       
       switch state_flag
           
           case 'X'
               
               Tab     = Had_Gate(Tab,qubit,n);
               Circuit = store_gate_oper(qubit,'H',Circuit,Store_Gates); 
               
           case 'Y'
               
               Tab = Phase_Gate(Tab,qubit,n);
               Tab = Had_Gate(Tab,qubit,n);
           
               Circuit = store_gate_oper(qubit,'P',Circuit,Store_Gates); 
               Circuit = store_gate_oper(qubit,'H',Circuit,Store_Gates); 
       end
       
   end
   
end


Tab=do_gauss(Tab,n);  %this will not update correctly destabilizers, but put them as Xs



end

function Tab=do_gauss(Tab,n)

col_start=1;
row_start=1;
ROW=1;
COL=1;


while ROW<=n && COL<=n

    for col=col_start:n

        temp = Tab(row_start:n,col+n);
        
        cond1 = temp>0;

        if any(cond1)
            
            nnz_rows   = find(temp); 
            row_loc    = nnz_rows(1);
            nnz_rows(1) = [];
            
            break
        end

    end

    %Use row operations to put a 1 in the topmost position of this column, i.e. SWAP the rows

    Tab = SWAP_rows(Tab,ROW,row_loc+(row_start-1)); %SWAP Stabilizers

    %Use elementary row operations to put 1s below the pivot position
    

    if ~isempty(nnz_rows)

        nnz_rows=nnz_rows+(row_start-1);

        nnz_rows(nnz_rows==ROW)=[]; %=setxor(nnz_rows,ROW);

        for jj=1:length(nnz_rows)

            Tab = rowsum(Tab,n,nnz_rows(jj),ROW); %Stab update

        end


    end


    nnz_full_rows=nnz(Tab(ROW+1:n,1:2*n));

    if nnz_full_rows==0
        break

    end

    ROW=ROW+1;   
    COL=COL+1;
    col_start=col_start+1;
    row_start=row_start+1;

end            


if ~all(all(eye(n,'int8')==Tab(:,1:n)))

    for col=n:-1:1

        nnz_rows=find(Tab(:,col+n));
        rrow=col;

        if length(nnz_rows)>=2

            nnz_rows(nnz_rows==col)=[];
           
            for ll=1:length(nnz_rows)

                Tab = rowsum(Tab,n,nnz_rows(ll),rrow);
                

            end


        end

    end



end


end

