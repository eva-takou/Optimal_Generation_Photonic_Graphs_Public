function row_indx_Stabs = Stabs_with_support_on_emitters(Tab,np,ne,not_absorbed_photons)
%Find stabilizers that have support only on the emitters.
%This script is used for the time-reversed measurements.
%Inputs:      Tableau, 
%        # of photons, 
%        # of emitters.
%        not_absorbed_photons: photons that have not yet been absorbed.
%Output: the row indices of stabilizers.

n     = np+ne;    

cnt   = 0;

for ii=n:-1:1  %n:-1:1 (I think it is safe to explore only from n till n-2*ne
    
    Sx_p = Tab(ii,not_absorbed_photons);
    
    if any(Sx_p)
        
        continue
        
    end
    
    Sz_p = Tab(ii,not_absorbed_photons+n);

    if any(Sz_p)
        
        continue
        
    end

    
    %Make sure that we do not have all identities on the emitters:
        
    Sx_em=Tab(ii,np+1:n);

    if any(Sx_em)

        cnt  = cnt+1;   
        row_indx_Stabs(cnt) = ii;

        continue

    end

    Sz_em=Tab(ii,np+1+n:2*n);

    if any(Sz_em) 

        cnt                 = cnt+1;    
        row_indx_Stabs(cnt) = ii;

    end

end

if cnt==0
    row_indx_Stabs=[];
end



end