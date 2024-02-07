function Adj=get_LC_representatives(n)
%Function to get the non-LC equivalent (including isomorphic) classes of
%order n.
%Input: order n
%Output: Adjacency matrices in cell array.

discard_isomorphism=false;

Adj=all_adjacencies(n,discard_isomorphism);

%Test LC equivalence
indx=[];
disp('Checking for LC equivalence:')
parfor k1=1:length(Adj)
    
    disp(['Running k1=',num2str(k1),' out of ',num2str(length(Adj))])
    for k2=k1+1:length(Adj)
        
        [~,flag,~]=LC_check(double(Adj{k1}),double(Adj{k2}));
        
        if flag
            
           indx=[indx,k2]; 
           break
           
        end
        
    end
    
end

Adj(indx)=[];


end