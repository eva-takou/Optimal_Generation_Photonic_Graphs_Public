function h=height_function(Tab_RREF,n,Request_nodes,j_indx)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: Feb 1, 2025
%--------------------------------------------------------------------------
%
%Function to calculate the entanglement entropy, given a
%particular ordering of the nodes. To reshuffle nodes we make use
%of permutation matrices.
%
%The height function is given by:
%h=@(x) n-x - number_of_gm| left index of Pauli of gm is in node_indx>x 
%
%Input: Tab_RREF: The tableau in RREF form
%       n: total # of qubits (photons+emitters)
%       Request_nodes: true or false to calculate just 2 points
%       j_indx: index to calculate 1 point (by default we calculate
%               also h(j_indx-1))
%Output: h: the height function

h = zeros(1,n+1);

if Request_nodes
    
    j_indx=j_indx-1;

   [trueX, xi] = max( Tab_RREF(:,1:n)'~=0, [], 1 );
   xi(~trueX)=nan;
   [trueZ, zi] = max( Tab_RREF(:,n+1:2*n)'~=0, [], 1 );
   zi(~trueZ)=nan;
   locs = min([xi;zi],[],1); 
   
    
    for ii=j_indx-1:j_indx

       x=ii; %current node

%------ Alternative way--------------
%        for ll=1:n %loop through stabs
%            
%            xi  = find(Stabs(ll,1:n),1);
%            zi  = find(Stabs(ll,n+1:2*n),1);
%            loc = min([xi,zi]);
% 
%            if loc>x
%               cnt=cnt+1; 
%            end
% 
%        end
%------------------------------------------

       cnt     = sum(locs>x);
       h(ii+1) = h(ii+1)+n-(x)-cnt;

    end
    
    
else
    
%     SX = Tab_RREF(:,1:n);
%     SZ = Tab_RREF(:,n+1:end-1);
    
    

   [trueX, xi] = max( Tab_RREF(:,1:n)'~=0, [], 1 );
   xi(~trueX)=nan;
   [trueZ, zi] = max( Tab_RREF(:,n+1:2*n)'~=0, [], 1 );
   zi(~trueZ)=nan;
   locs = min([xi;zi],[],1); 
   
    for ii=1:(n-1)

       x=(ii); %current node

%        cnt=0;
% 
%        for ll=1:n %loop through stabs
% 
%            xi=find(SX(ll,:),1,'first');
%            zi=find(SZ(ll,:),1,'first');
% 
%            loc=min([xi,zi]);
% 
%            if loc>x
%               cnt=cnt+1; 
%            end
% 
%        end

       cnt     = sum(locs>x);
       h(ii+1)=h(ii+1)+n-(x)-cnt;

    end
    
end

end