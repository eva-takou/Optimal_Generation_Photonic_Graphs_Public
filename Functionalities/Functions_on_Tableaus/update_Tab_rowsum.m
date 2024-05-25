function Tab=update_Tab_rowsum(Tab,n,row_replace,row)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 25, 2024
%--------------------------------------------------------------------------
%
%Function to update the Tableau after row-sum operation.
%Inputs: Tab: Input stabilizer Tableau (n x 2n+1 array)
%          n: Total # of qubits
%        row_replace: the row we are replacing with Rj*Rk
%        row: the row we are multiplying to row_replace
%Output: Tab: The updated Tableau
%Input rows need to be from 1 till n, (stabilizer row).

Tab = rowsum(Tab,n,row_replace,row);
%If we had destab/stab tableau we would also do
%rowsum(Tab,n,row-n,row_replace-n)


end