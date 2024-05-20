function Q_i = Reconstruct_Qis(sols)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Input: sols for the constrained Ax=0 problem. Each sol in sols 
%       is one null-vector that satisfied the constraints.
%Output: Matrix Q_i for the local gate.
%

L = length(sols{1});
n = L/4;

for jj=1:length(sols)

    [a_s,b_s,c_s,d_s] = Get_abcd_coeffs(sols{jj},n);

    for ii=1:n

        Q_i{jj}{ii} = int8([a_s(ii), b_s(ii);...
                              c_s(ii), d_s(ii)]);

    end

end


end
