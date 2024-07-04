function RGS_opt_ordering_circuit
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 25, 2024
%
%Plot the generation circuit of an RGS with optimal emission ordering that
%requires 2 emitters.
%Plot also the generation circuit of an RGS with multiple leaves per core
%qubit and optimal emission ordering.

close all; clc; clear;

n              = 6;     %#of core nodes of RGS
node_ordering  = 1:2*n; %node ordering (clock-wise)
Store_Graphs   = false;
Store_Gates    = true;
Verify_Circuit = true;
return_cond    = false; %Enable extra inspection for free PA
BackSubsOption = true;  %Enable Back-substitution

%------- For the circuit plot ---------------------------------------------
layer_shift       = 1;
Init_State_Option = '0';
CircOrder         = 'backward';

%------- For the Graph plot -----------------------------------------------
MS_Size = 8;
FNtsize = 17;
LNwidth = 2;
%------ For the circuit simplification plot -------------------------------
ConvertToCZ         = false;
pass_X_photons      = true;
pass_emitter_Paulis = false;
monitor_update      = false;
pause_time          = 0.0001;
fignum              = 100;


%------ RGS with 1 leaf per core node -------------------------------------
Adj  = create_opt_ordering_RGS_many_leaves(n,1);
temp = Tableau_Class(Adj,'Adjacency');
temp = temp.Generation_Circuit_Heu1(node_ordering,Store_Graphs,...
                                  Store_Gates,BackSubsOption,...
                                  Verify_Circuit,return_cond,[]);
ne        = temp.Emitters;
np        = length(Adj);
Circ      = temp.Photonic_Generation_Gate_Sequence;
Circ      = fix_potential_phases_forward_circuit(Circ,Adj,ne,CircOrder);
Circ      = Simplify_Circuit(Circ,np,ne,CircOrder,ConvertToCZ,pass_X_photons,...
                             pass_emitter_Paulis,Init_State_Option,...
                             monitor_update,pause_time,fignum);


%------- Plot the results for the first RGS -------------------------------
figure(1)
draw_circuit(np,ne,Circ,CircOrder,layer_shift,Init_State_Option)
figure(2)
plot(graph(double(Adj)),'Nodecolor','k','linewidth',LNwidth,'markersize',MS_Size,'nodefontsize',FNtsize)

%------ RGS with 2 leaves per core node -----------------------------------

Adj  = create_opt_ordering_RGS_many_leaves(n,2);
node_ordering = 1:length(Adj);
temp = Tableau_Class(Adj,'Adjacency');
temp = temp.Generation_Circuit_Heu1(node_ordering,Store_Graphs,...
                                  Store_Gates,BackSubsOption,...
                                  Verify_Circuit,return_cond,[]);
np   = length(Adj);
ne   = temp.Emitters;
Circ = temp.Photonic_Generation_Gate_Sequence;
%Circ = pass_X_gates(Circ,np,CircOrder);
Circ = fix_potential_phases_forward_circuit(Circ,Adj,ne,CircOrder);
Circ = Simplify_Circuit(Circ,np,ne,CircOrder,ConvertToCZ,pass_X_photons,...
                             pass_emitter_Paulis,Init_State_Option,...
                             monitor_update,pause_time,fignum);

%------- Plot the results for the second RGS ------------------------------

figure(3)
draw_circuit(np,ne,Circ,CircOrder,layer_shift,Init_State_Option)
figure(4)
plot(graph(double(Adj)),'Nodecolor','k','linewidth',LNwidth,...
    'markersize',MS_Size,'nodefontsize',FNtsize,'layout','circle')

end