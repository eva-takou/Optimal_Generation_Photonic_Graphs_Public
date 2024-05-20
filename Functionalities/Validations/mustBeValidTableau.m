function mustBeValidTableau(Tableau)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 20, 2024
%
%Throw an error if the stabilizer Tableau is not valid.
%Input: Tableau: The stabilizer tableau (n x 2n+1 array) 

[n,~] = size(Tableau);
S     = Tableau(1:n,1:2*n);

mustBeStabGroup(S) 

end