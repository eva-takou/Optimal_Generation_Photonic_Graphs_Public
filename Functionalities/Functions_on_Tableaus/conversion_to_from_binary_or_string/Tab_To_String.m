function [stab_str]=Tab_To_String(Tab)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 25, 2024
%
%Function to output the stabilizer of a tableau as Pauli strings.
%Input: Tab: The stabilizer tableau (n x 2n+1 array)
%Output: stab_str: the stabilizer Pauli strings in cell array

n          = (size(Tab,2)-1)/2;
stab_str   = cell(1,n);

for ii=1:n %Stabs

    for jj=1:n

        if Tab(ii,jj)==0 && Tab(ii,jj+n)==0 

            this_stab(jj)='I';

        elseif Tab(ii,jj)==1 && Tab(ii,jj+n)==0 

            this_stab(jj)='X';

        elseif Tab(ii,jj)==1 && Tab(ii,jj+n)==1 

            this_stab(jj)='Y';

        elseif Tab(ii,jj)==0 && Tab(ii,jj+n)==1 

            this_stab(jj)='Z';

        end

        if Tab(ii,end)==0

            phase='+';

        elseif Tab(ii,end)==1

            phase='-';

        end

        stab_str{ii}=[phase,this_stab];

    end

end


end
