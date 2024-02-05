function [All_Gammas]=Get_Adjacency_all(Tab)
%Function to get all passible adjacency matrices from a stabilizer state.

n  = (size(Tab,2)-1)/2;
Sx = Tab(:,1:n);
Sz = Tab(:,n+1:2*n);
k  = sprank_GF2(Sx);
All_Gammas={};

if k==n %Graph state uniquely defined, no Hadamard

    [Sz,~]=Get_Adjacency(Tab);
    
    
    All_Gammas{1}=Sz;
    

    mustBeValidAdjacency(Sz)
    
    return
    
elseif k<n 
    
    %Run a subroutine to find all submatrices of Sx with rank k.
    
    qubits=nchoosek(1:n,k);
    
    cnt=0;
    
    for l=1:size(qubits,1)
        
        comb    = qubits(l,:);
        Sx_red  = Sx(:,comb);
        
        test_rank = sprank_GF2(Sx_red);
        
        if test_rank==k
            
            cnt                 = cnt+1;            
            qubits_for_Had{cnt} = setxor(1:n,comb);
            
        end
        
    end
    
    
    for l=1:length(qubits_for_Had)
        
        newTab=Tab;
        
        for p=1:length(qubits_for_Had{l})
            
            newTab=Clifford_Gate(newTab,qubits_for_Had{l}(p),'H');
            
        end
        
        %Check that the binary rank is now n:
        if sprank_GF2(newTab(:,1:n))~=n
           
            error('Application of Hadamards did not make the matrix full rank.') 
           
        end
        
        %Now run the standard procedure of getting the adjacency matrix for
        %every newTab we generate, via gaussian elimination.
        [tempAdj,~]=Get_Adjacency(newTab); %All these graph representations
                                           %are not equivalent by LC.
                                           %Additionally, Gaussian
                                           %elimination should give freedom to LC. 
                                           %But, this is computationally
                                           %intensive, because to find also LC answers
                                           %we need to not allow rowswaps
                                           %but instead to find how we
                                           %should rowsum and what gates we
                                           %should apply.
        
        All_Gammas=[All_Gammas,{tempAdj}];
        
    end
    
    
end






end