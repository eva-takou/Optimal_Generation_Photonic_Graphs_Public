function cond = Test_abcd_constraint(NullVec,n)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Input:  NullVec: A single null-vector 4x x 1.
%        n: 1/4 of the total unknowns a's, b's, c's, d's.
%Output: True or False (whether or not the NullVector satisfies the
%        constraint det(Qi)=1).

[a_s,b_s,c_s,d_s] = Get_abcd_coeffs(NullVec,n);

if all(mod(a_s.*d_s+b_s.*c_s,2)==1)
    cond=true;
else
    cond=false;
end

end
