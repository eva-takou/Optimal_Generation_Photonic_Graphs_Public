function Q_i = Reconstruct_Qis(sols)
%Each sol is one null-vector that satisfied the constraints.

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
