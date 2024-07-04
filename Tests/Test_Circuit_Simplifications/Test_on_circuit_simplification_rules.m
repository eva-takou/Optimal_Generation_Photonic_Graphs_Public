%% Inspect equivalence of circuits based on state vector after simplifications

close all; clc; clear; warning('off')

%-------- Generate a circuit based on the Naive approach ------------------

Store_Graphs   = false;
Store_Gates    = true;
BackSubsOption = false; %No back-substitution on Stabs
Verify_Circuit = true;
return_cond    = true;  %Do not exhaust all checks for free PA


circuitOrder        = 'forward';
Init_State_Option   = '0';
monitor_update      = false;
pause_time          = 0.0001;
fignum              = 1;


iterMax = 15;
np      = 6;


for iter = 1:iterMax
    
    Adj = create_random_graph(np);
    test = Tableau_Class(Adj,'Adjacency');
    test = test.Generation_Circuit(1:np,Store_Graphs,Store_Gates,BackSubsOption,...
                                   Verify_Circuit,return_cond);
    Circuit = test.Photonic_Generation_Gate_Sequence; %Backwards order
    ne      = test.Emitters;
    n       = ne+np;    
    
    %--------- Get state after applying this circuit ----------------------
    Circuit_Forward = put_circuit_forward_order(Circuit);
    psi_1           = update_state_vector_circuit_instructions(Circuit_Forward,'forward');

    %----- Apply some simplifications and re-check the state vector -------
    
    ConvertToCZ         = false;
    pass_X_photons      = true;
    pass_emitter_Paulis = false;
    
    [New_Circuit]=Simplify_Circuit(Circuit_Forward,np,ne,circuitOrder,ConvertToCZ,...
                                               pass_X_photons,pass_emitter_Paulis,...
                                               Init_State_Option,...
                                               monitor_update,pause_time,fignum);
                                           
    psi_2 = update_state_vector_circuit_instructions(New_Circuit,'forward');                                                                                  
    
    %------- Uncomment to plot the circuits ------------------------------- 
    % figure(1)
    % clf;
    % subplot(2,1,1)
    % draw_circuit(np,ne,Circuit_Forward,'forward',1,'0')
    % subplot(2,1,2)
    % draw_circuit(np,ne,New_Circuit,'forward',1,'0')    
    
    prob(1) = abs(psi_2'*psi_1)^2;
    
    %---- Do more simplifications (commute Pauli's of emitter qubits) -----
    
    ConvertToCZ         = false;
    pass_X_photons      = true;
    pass_emitter_Paulis = true;
    
    
    [New_Circuit_3]=Simplify_Circuit(Circuit_Forward,np,ne,circuitOrder,ConvertToCZ,...
                                               pass_X_photons,pass_emitter_Paulis,...
                                               Init_State_Option,...
                                               monitor_update,pause_time,fignum);

    %----- Uncomment to plot the circuits ---------------------------------                                       
    % figure(2)
    % clf;
    % subplot(2,1,1)
    % draw_circuit(np,ne,Circuit_Forward,'forward',1,'0')
    % subplot(2,1,2)
    % draw_circuit(np,ne,New_Circuit_3,'forward',1,'0')
    
    psi_3 = update_state_vector_circuit_instructions(New_Circuit_3,'forward');                                                                                  
    
    prob(2) = abs(psi_3'*psi_1)^2;
    
    %-- Do more simplifications (commute Pauli's of emitter qubits & convert CNOT->CZ)    
    ConvertToCZ         = true;
    pass_X_photons      = true;
    pass_emitter_Paulis = true;
    
    
    [New_Circuit_4]=Simplify_Circuit(Circuit_Forward,np,ne,circuitOrder,ConvertToCZ,...
                                               pass_X_photons,pass_emitter_Paulis,...
                                               Init_State_Option,...
                                               monitor_update,pause_time,fignum);

                                           
    %----- Uncomment to plot the circuits ---------------------------------                                                                              
    % figure(3)
    % clf;
    % subplot(2,1,1)
    % draw_circuit(np,ne,Circuit_Forward,'forward',1,'0')
    % subplot(2,1,2)
    % draw_circuit(np,ne,New_Circuit_4,'forward',1,'0')
        
    psi_4 = update_state_vector_circuit_instructions(New_Circuit_4,'forward');                                       
    
    
    prob(3) = abs(psi_4'*psi_1)^2;
    
    
    if any(abs(prob-1)>1e-9)
        
        error('Equivalence is false.')
        
    end
    
end