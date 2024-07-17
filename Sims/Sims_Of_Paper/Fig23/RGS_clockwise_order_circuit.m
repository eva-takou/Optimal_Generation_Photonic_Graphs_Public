function RGS_clockwise_order_circuit
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 25, 2024
%
%Plot the generation circuit of an RGS with clock-wise emission ordering.


close all;

n              = 6;     %#of core nodes of RGS
node_ordering  = 1:2*n; %node ordering (clock-wise)
Store_Graphs   = false;
Store_Gates    = true;
Verify_Circuit = true;
return_cond    = true; %Do not enable extra inspection for free PA
BackSubsOption = true; %Enable Back-substitution


%------- For the Graph plot -----------------------------------------------
MS_Size = 8;
FNtsize = 17;
LNwidth = 2;
%--------------------------------------------------------------------------

Adj  = create_RGS(n,1:2*n,n,'Adjacency');
temp = Tableau_Class(Adj,'Adjacency');
temp = temp.Generation_Circuit_Heu1(node_ordering,Store_Graphs,...
                                  Store_Gates,BackSubsOption,...
                                  Verify_Circuit,return_cond);

Circ = temp.Photonic_Generation_Gate_Sequence;
CircOrder = 'backward';
np   = length(Adj);
ne   = temp.Emitters;
layer_shift=1;
Init_State_Option = '0';


draw_circuit(np,ne,Circ,CircOrder,layer_shift,Init_State_Option)

figure(2)
plot(graph(double(Adj)),'Nodecolor','k','linewidth',LNwidth,...
    'markersize',MS_Size,'nodefontsize',FNtsize,'layout','force')


end