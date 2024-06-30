%% Draw a circuit after the circuit updates


close all; clc; clear;

Store_Graphs   = false;
Store_Gates    = true;
BackSubsOption = false;
Verify_Circuit = true;
return_cond    = true;

np  = 8;
Adj = create_random_graph(np);

test = Tableau_Class(Adj,'Adjacency');
test = test.Generation_Circuit(1:np,Store_Graphs,Store_Gates,BackSubsOption,...
                             Verify_Circuit,return_cond);
Circuit = test.Photonic_Generation_Gate_Sequence;

%%

close all
circuitOrder        = 'backward';
ne                  = test.Emitters;
n                   = np+ne;
ConvertToCZ         = true;
pass_X_photons      = true;
pass_emitter_Paulis = true;
Init_State_Option   = '0';
monitor_update      = true;
pause_time          = 0.05;
fignum              = 1;


[New_Circuit]=Simplify_Circuit(Circuit,np,ne,circuitOrder,ConvertToCZ,...
                                           pass_X_photons,pass_emitter_Paulis,...
                                           Init_State_Option,...
                                           monitor_update,pause_time,fignum);