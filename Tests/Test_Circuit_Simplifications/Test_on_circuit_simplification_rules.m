%% Inspect equivalence of circuits after simplifications

close all; clc; clear; warning('off')

%-------- Generate a circuit based on the Naive approach ------------------

Store_Graphs   = false;
Store_Gates    = true;
BackSubsOption = false; %No back-substitution on Stabs
Verify_Circuit = true;
return_cond    = true;  %Do not exhaust all checks for free PA

np  = 7;
Adj = create_random_graph(np);
test = Tableau_Class(Adj,'Adjacency');
test = test.Generation_Circuit(1:np,Store_Graphs,Store_Gates,BackSubsOption,...
                               Verify_Circuit,return_cond);
Circuit = test.Photonic_Generation_Gate_Sequence; %Backwards order
ne      = test.Emitters;
n       = ne+np;

%% Get state after applying this circuit
clc;
Circuit_Forward = put_circuit_forward_order(Circuit);
psi_1           = update_state_vector_circuit_instructions(Circuit_Forward,'forward');

%% Now try some simplifications and re-check the state vector

circuitOrder        = 'forward';
ConvertToCZ         = false;
pass_X_photons      = true;
pass_emitter_Paulis = false;
Init_State_Option   = '0';
monitor_update      = false;
pause_time          = 0.0001;
fignum              = 1;


[New_Circuit]=Simplify_Circuit(Circuit_Forward,np,ne,circuitOrder,ConvertToCZ,...
                                           pass_X_photons,pass_emitter_Paulis,...
                                           Init_State_Option,...
                                           monitor_update,pause_time,fignum);

                                       
psi_2 = update_state_vector_circuit_instructions(New_Circuit,'forward');                                       

figure(1)
clf;
subplot(2,1,1)
draw_circuit(np,ne,Circuit_Forward,'forward',1,'0')
subplot(2,1,2)
draw_circuit(np,ne,New_Circuit,'forward',1,'0')
                                    
%Compare the states:
clc;
disp(['State overlap <\psi_1|psi_2>: ',num2str(psi_2'*psi_1)])


bool=check_equivalence_Clifford_Circuits(Circuit_Forward,New_Circuit,'forward')
                                       
%% Do more simplifications (commute Pauli's of emitter qubits)

circuitOrder        = 'forward';
ConvertToCZ         = false;
pass_X_photons      = true;
pass_emitter_Paulis = true;
Init_State_Option   = '0';
monitor_update      = false;
pause_time          = 0.0001;
fignum              = 1;


[New_Circuit_3]=Simplify_Circuit(Circuit_Forward,np,ne,circuitOrder,ConvertToCZ,...
                                           pass_X_photons,pass_emitter_Paulis,...
                                           Init_State_Option,...
                                           monitor_update,pause_time,fignum);
figure(2)
clf;
subplot(2,1,1)
draw_circuit(np,ne,Circuit_Forward,'forward',1,'0')
subplot(2,1,2)
draw_circuit(np,ne,New_Circuit_3,'forward',1,'0')
                                       
psi_3 = update_state_vector_circuit_instructions(New_Circuit_3,'forward');                                       

%Compare the states:
clc;
disp(['State overlap <\psi_1|psi_3>: ',num2str(psi_3'*psi_1)])

bool=check_equivalence_Clifford_Circuits(Circuit_Forward,New_Circuit_3,'forward')

%% Do more simplifications (commute Pauli's of emitter qubits & convert CNOT->CZ)

circuitOrder        = 'forward';
ConvertToCZ         = true;
pass_X_photons      = true;
pass_emitter_Paulis = true;
Init_State_Option   = '0';
monitor_update      = false;
pause_time          = 0.0001;
fignum              = 1;


[New_Circuit_4]=Simplify_Circuit(Circuit_Forward,np,ne,circuitOrder,ConvertToCZ,...
                                           pass_X_photons,pass_emitter_Paulis,...
                                           Init_State_Option,...
                                           monitor_update,pause_time,fignum);
figure(3)
clf;
subplot(2,1,1)
draw_circuit(np,ne,Circuit_Forward,'forward',1,'0')
subplot(2,1,2)
draw_circuit(np,ne,New_Circuit_4,'forward',1,'0')
                                       
psi_4 = update_state_vector_circuit_instructions(New_Circuit_4,'forward');                                       

%Compare the states:
clc;
disp(['State overlap <\psi_1|psi_4>: ',num2str(psi_4'*psi_1)])
disp(['Prob: <\psi_1|psi_4>: ',num2str(abs(psi_4'*psi_1)^2)])


bool=check_equivalence_Clifford_Circuits(Circuit_Forward,New_Circuit_4,'forward')
