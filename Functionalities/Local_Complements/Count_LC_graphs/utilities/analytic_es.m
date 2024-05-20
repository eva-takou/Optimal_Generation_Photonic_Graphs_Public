function e=analytic_es(n,graphtype)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%
%Get the index e(G) for various graph types.
%
%Input: n: # of graph nodes
%      graphtype: can be: 'Pn', 'Kn','Sn', 'RGS_n_n', 'Cn'
%Output: The value of e(G) for the closed-form expression.


switch graphtype
    
    
    case 'Pn' %OK
        
        e = sqrt(3)/6*( (1+sqrt(3))^(n+1)-(1-sqrt(3))^(n+1) );
        
    case 'Sn' %OK
        
        e = 2^(n-1)*(n+1);
        
        
    case 'Kn'%OK
        
        e = 2^(n-1)*(n+1);
         
    case 'RGS_n_n' %OK
        
        e = 2^(n-1)+6^(n-1)*(3+2*n);
        
    case 'Cn'
        
        if n>3 %OK
            
            e = (1+sqrt(3))^n+(1-sqrt(3))^n-4/3*(2^(n-1)+(-1)^n) ;
            
        else
            
            error('The Cn graph is defined for n>=3.')
           
        end
        
end


end