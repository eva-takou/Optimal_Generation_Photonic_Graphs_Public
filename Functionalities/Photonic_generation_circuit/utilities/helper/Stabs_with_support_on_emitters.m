function row_indx_Stabs = Stabs_with_support_on_emitters(Tab,np,ne) %,not_absorbed_photons
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 15, 2024
%--------------------------------------------------------------------------
%
%Find stabilizers that have support only on the emitters.
%This script is used for the time-reversed measurements.
%Inputs:      Tableau, 
%        # of photons, 
%        # of emitters.
%Output: the row indices of stabilizers.


n     = np+ne;    
cnt   = 0;

Xp    = Tab(:,1:np);
Zp    = Tab(:,n+1:n+np);
Xem   = Tab(:,np+1:n);
Zem   = Tab(:,np+1+n:2*n);

for ii=n:-1:1  
    
    Sx_p = Xp(ii,:);
    
    if any(Sx_p>0)
        
        continue
        
    end
    
    Sz_p = Zp(ii,:);
    
    if any(Sz_p>0)
        
        continue
        
    end

    %Make sure that we do not have all identities on the emitters:
     
    Sx_em = Xem(ii,:);

    if any(Sx_em)

        cnt  = cnt+1;   
        row_indx_Stabs(cnt) = ii;

        continue

    end

    Sz_em = Zem(ii,:);

    if any(Sz_em) 

        cnt                 = cnt+1;    
        row_indx_Stabs(cnt) = ii;

    end

end

if cnt==0
    row_indx_Stabs=[];
end



end