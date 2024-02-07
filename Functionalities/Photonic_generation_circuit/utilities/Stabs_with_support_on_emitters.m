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

for ii=n:-1:1  
    
    %Sx_p = Tab(ii,not_absorbed_photons); %Do not consider those w support on photons at all?
    Sx_p = Tab(ii,1:np);
    
    if any(Sx_p>0)
        
        continue
        
    end
    
    %Sz_p = Tab(ii,not_absorbed_photons+n);
    Sz_p = Tab(ii,n+1:n+np);

    if any(Sz_p>0)
        
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