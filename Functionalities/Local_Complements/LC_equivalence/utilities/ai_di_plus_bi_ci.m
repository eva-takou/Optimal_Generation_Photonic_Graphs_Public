function  value = ai_di_plus_bi_ci(VEC,ith_entry)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Input: VEC: A vector x (4n x 1) which contains the coefficients
%            [c_1 ... c_n a_1 ... a_n d_1 ... d_n b_1 ... b_n]^T.
%       ith_entry: the i-th entries of the coeffs a's, b's, c's, d's
%
%Output: The value a_i*d_i+b_i*c_i for a particular i \in [1,n]
%


n     = length(VEC)/4;

if ith_entry>n || ith_entry==0
   
    error('The i index needs to be in [1,n].') 
    
end

value = mod( VEC(ith_entry+n)*VEC(ith_entry+2*n) + VEC(ith_entry)*VEC(ith_entry+3*n) ,2);

end
