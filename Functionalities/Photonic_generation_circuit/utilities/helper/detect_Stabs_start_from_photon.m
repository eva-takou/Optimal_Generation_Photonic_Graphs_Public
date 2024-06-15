function [potential_rows,photon_flag_Gate,Tab]=detect_Stabs_start_from_photon(Tab,photon,n)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 15, 2024
%--------------------------------------------------------------------------
%
%Function to detect a stab whose Left index starts from the photon to be 
%absorbed.
%
%Input: Tab: Tableau
%       photon: the photon index that we intend to absorb
%       n: total # of qubits (photons+emitters)
%Output: potential rows: an array all the stabilizer rows where the first 
%                        non-trivial Pauli starts on the photon.
%        photon_flag_Gate: a cell of the Pauli that acts on the photon in
%        each case
%        Tab: The input tableau is returned back (nothing changes)
%
%#TODO#: Can reduce the search further by providing the information
%        of which rows on photons have become I on the photonic stabs.
%        Those are rows we should not be checking again.

StabsXp = Tab(:,1:photon-1);
StabsZp = Tab(:,n+1:n+(photon-1));

cnt   = 0;

photon_flag_Gate=cell(1,2);
potential_rows=zeros(1,2);

if photon>1

    if photon>=n/2
       
        indx_start=n;
        step=-1;
        indx_end=1;
       
    else
        
        indx_start=1;
        step=1;
        indx_end=n;
        
    end
    
    for ii=indx_start:step:indx_end %Should not inspect that many rows. Should exclude last rows that were already processed..

        SX_other_photons = StabsXp(ii,:);
        
        if any(SX_other_photons)
            
            continue
            
        end
        
        SZ_other_photons = StabsZp(ii,:);
        
        if any(SZ_other_photons)
            
            continue
            
        end
        
        xi_target_photon = Tab(ii,photon);
        zi_target_photon = Tab(ii,photon+n);

        if xi_target_photon==0 && zi_target_photon==1 %Conditions for non-trivial Paulis on target photon.

            cnt = cnt+1;
            photon_flag_Gate{cnt} = 'Z';
            potential_rows(cnt)   = ii;

        elseif xi_target_photon==1 && zi_target_photon==1

            cnt = cnt+1;
            photon_flag_Gate{cnt} = 'Y';
            potential_rows(cnt)   = ii;

        elseif xi_target_photon==1 && zi_target_photon==0    

            cnt = cnt+1;
            photon_flag_Gate{cnt} = 'X';
            potential_rows(cnt)   = ii;

        end

        %We will have at most 2 photonic rows, due to RREF.
        if cnt==2
            break
        end

    end
    
elseif photon==1
    
    for ii=1:n

        xi_target_photon = Tab(ii,photon);
        zi_target_photon = Tab(ii,photon+n);

        if xi_target_photon==0 && zi_target_photon==1 %Conditions for non-trivial Paulis on target photon.

            cnt = cnt+1;
            photon_flag_Gate{cnt} = 'Z';
            potential_rows(cnt)   = ii;

        elseif xi_target_photon==1 && zi_target_photon==1

            cnt = cnt+1;
            photon_flag_Gate{cnt} = 'Y';
            potential_rows(cnt)   = ii;

        elseif xi_target_photon==1 && zi_target_photon==0    

            cnt = cnt+1;
            photon_flag_Gate{cnt} = 'X';
            potential_rows(cnt)   = ii;

        end

        if cnt==2
            break
        end        
        
    end
    

    
end

if cnt==0
    
    error('Did not find Stab whose 1st Pauli starts from photon to be absorbed.')
    
end

if cnt==1
    
    photon_flag_Gate(2)=[];
    potential_rows(2)=[];
end

end
