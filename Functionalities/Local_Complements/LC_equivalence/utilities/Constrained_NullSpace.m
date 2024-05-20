function sols = Constrained_NullSpace(NullVecMatrix)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Constrain the null-space to find if there is a solution for the two graphs
%to be LC equivalent.
%When dimV<=4 we can enumerate all 16-1 (trivial) possibilities of adding vectors together.
%
%Input: NullVecMatrix: An 4n x # of free variables matrix whose columns are the null vectors (unconstrained).
%Output: sols: solutions that solve Ax = 0 , with the constraint that det(Q_i)=1
%        If there are no solutions, sols is an empty array.

[k,dimV]  = size(NullVecMatrix); %k=4n
n         = k/4; 
sol_count = 0;

if dimV<=4

    combs        = dec2bin(0:2^dimV-1)' - '0'; %read column-wise
    num_of_combs = size(combs,2);

    for jj=2:num_of_combs %Loop through adding 1,2,3,4 vectors together

        nulls_to_add = find(combs(:,jj));
        inspect_Vec  = zeros(4*n,1,'int8');
        
        for ll=1:length(nulls_to_add)

            inspect_Vec = inspect_Vec + NullVecMatrix(:,nulls_to_add(ll));

        end

        inspect_Vec = mod(inspect_Vec,2);
        sol_Found   = Test_abcd_constraint(inspect_Vec,n);

        if sol_Found

            sol_count       = sol_count+1;
            sols{sol_count} = inspect_Vec;

        end

    end

else %Do not enumerate all vectors--inspect only combinations of adding 2 basis vecs.

     for l1=1:dimV

         for l2=l1+1:dimV 

             inspect_Vec = mod(NullVecMatrix(:,l1)+NullVecMatrix(:,l2),2);
             sol_Found   = Test_abcd_constraint(inspect_Vec,n);

             if sol_Found %Solution found.
                 
                 sol_count       = sol_count+1;
                 sols{sol_count} = inspect_Vec;
                 
             end

         end

     end
     
     for l1=1:dimV %Check also every vector against the constraints

         inspect_Vec = NullVecMatrix(:,l1);
         sol_Found   = Test_abcd_constraint(inspect_Vec,n);
         
         if sol_Found %Solution found
             
             sol_count       = sol_count+1;
             sols{sol_count} = inspect_Vec;
             
         end
     end

end

if sol_count==0

    sols=[]; %Input graphs are not LC equivalent

end

end
