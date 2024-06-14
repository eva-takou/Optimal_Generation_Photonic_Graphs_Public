function Tab_Aug = AugmentTableau(Tab,ne)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 14, 2024
%--------------------------------------------------------------------------
%
%Function to augment the tableau with emitters in |0> (operators of the form
%II...ZI...II). 
%
%Inputs: Tab (in RREF)
%        ne  (# of emitters needed to generate the graph)
%        The # of emitters is determined by the height fun.
%Output: The augmented tableau where we initialize emitters in |0>.

np = (size(Tab,2)-1)/2;
n  = np+ne;

%Stabs augmented in total space

Sx     = [Tab(1:np,1:np)      , zeros(np,ne,'int8')];
Sz     = [Tab(1:np,np+1:2*np) , zeros(np,ne,'int8')]; %all np x n size


ph_S   = [Tab(1:np,2*np+1)      ; zeros(ne,1,'int8')]; % n x 1 size

%Initialize the emitters in |0>

Sx_em = zeros(ne,n,'int8');                    %ne x n in size
Sz_em = [zeros(ne,np,'int8') , eye(ne,'int8')];     %ne x n in size

Sx = [Sx;Sx_em];
Sz = [Sz;Sz_em];
S  = [Sx,Sz];

Tab_Aug = S;      
ph      = ph_S; 

Tab_Aug=[Tab_Aug,ph];

end
