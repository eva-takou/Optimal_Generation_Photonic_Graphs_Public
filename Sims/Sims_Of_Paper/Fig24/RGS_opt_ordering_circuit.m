function RGS_opt_ordering_circuit
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 25, 2024
%
%Plot the generation circuit of an RGS with optimal emission ordering that
%requires 2 emitters.
%Plot also the generation circuit of an RGS with multiple leaves per core
%qubit and optimal emission ordering.


close all;

n              = 6;     %#of core nodes of RGS
node_ordering  = 1:2*n; %node ordering (clock-wise)
Store_Graphs   = false;
Store_Gates    = true;
Verify_Circuit = true;
return_cond    = false; %Enable extra inspection for free PA
BackSubsOption = true;  %Enable Back-substitution

%------ 1 leaf per core node --------------------------------------------
Adj  = create_opt_ordering_RGS_many_leaves(n,1);
temp = Tableau_Class(Adj,'Adjacency');
temp = temp.Generation_Circuit_Heu1(node_ordering,Store_Graphs,...
                                  Store_Gates,BackSubsOption,...
                                  Verify_Circuit,return_cond,[]);

Circ = temp.Photonic_Generation_Gate_Sequence;
CircOrder = 'backward';
np   = length(Adj);
ne   = temp.Emitters;
layer_shift=1;
Init_State_Option = '0';

figure(1)
draw_circuit(np,ne,Circ,CircOrder,layer_shift,Init_State_Option)
figure(2)
plot(graph(double(Adj)),'Nodecolor','k','linewidth',1.2,...
    'markersize',6,'nodefontsize',12)

%------ 2 leaves per core node --------------------------------------------

Adj  = create_opt_ordering_RGS_many_leaves(n,2);
node_ordering = 1:length(Adj);
temp = Tableau_Class(Adj,'Adjacency');
temp = temp.Generation_Circuit_Heu1(node_ordering,Store_Graphs,...
                                  Store_Gates,BackSubsOption,...
                                  Verify_Circuit,return_cond,[]);

Circ = temp.Photonic_Generation_Gate_Sequence;
np   = length(Adj);
Circ = pass_X_gates(Circ,np);

CircOrder = 'backward';
np   = length(Adj);
ne   = temp.Emitters;
layer_shift=1;
Init_State_Option = '0';

figure(3)
draw_circuit(np,ne,Circ,CircOrder,layer_shift,Init_State_Option)
figure(4)
plot(graph(double(Adj)),'Nodecolor','k','linewidth',1.2,...
    'markersize',6,'nodefontsize',12,'layout','circle')



end