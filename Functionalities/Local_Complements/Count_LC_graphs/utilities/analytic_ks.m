function k=analytic_ks(n,graphtype)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%
%Get the index e(G) for various graph types.
%
%Input: n: # of graph nodes
%      graphtype: can be: 'Pn', 'Kn','Sn', 'RGS_n_n', 'Cn'
%Output: The value of k(G) for the closed-form expression.


switch graphtype
    
    
    case 'Pn' %OK
        
        if n==2
            
            k = 6;
            
        elseif n>2
            
            k = 4;
            
        end
        
        
    case 'Sn' %OK
        
        if n==2
            k=6;
        else
            k = 2^(n-1);
        end
        
        
    case 'Kn' %OK
        
        if n==2
            k=6;
        else
            k = 2^(n-1);
        end
        
    case 'RGS_n_n'  
        
        k = 2^(n/2);
        
    case 'Cn' %OK
        
        if n>=5
            
            k = 1 ;
            
        elseif n==4 
            
            k = 4;
            
        elseif n==3 %becomes the Kn
            
            k = 2^(n-1);
            
        else
            
            error('The Cn graph needs to have at least 3 nodes.')
           
            
        end
        
        
        
end




end