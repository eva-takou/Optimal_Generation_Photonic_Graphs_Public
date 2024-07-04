%% Inspect equivalence of circuits after simplifications

close all; clc; clear; warning('off')

%-------- Generate a circuit based on the Naive approach ------------------

Store_Graphs   = false;
Store_Gates    = true;
BackSubsOption = false; %No back-substitution on Stabs
Verify_Circuit = true;
return_cond    = true;  %Do not exhaust all checks for free PA

np          = 15;
repeat_Test = 20;

circuitOrder        = 'forward';
Init_State_Option   = '0';
monitor_update      = false;
pause_time          = 0.0001;
fignum              = 1;

for iter=1:repeat_Test

    Adj = create_random_graph(np);
    test = Tableau_Class(Adj,'Adjacency');
    test = test.Generation_Circuit(1:np,Store_Graphs,Store_Gates,BackSubsOption,...
                                   Verify_Circuit,return_cond);
    Circuit = test.Photonic_Generation_Gate_Sequence; %Backwards order
    ne      = test.Emitters;
    n       = ne+np;

    Circuit_Forward = put_circuit_forward_order(Circuit);

    %------- Commute potential X-gates on photons -----------------------------

    ConvertToCZ         = false;
    pass_X_photons      = true;
    pass_emitter_Paulis = false;


    [New_Circuit]=Simplify_Circuit(Circuit_Forward,np,ne,circuitOrder,ConvertToCZ,...
                                               pass_X_photons,pass_emitter_Paulis,...
                                               Init_State_Option,...
                                               monitor_update,pause_time,fignum);

    bool=check_equivalence_Clifford_Circuits(Circuit_Forward,New_Circuit,'forward');

    if bool

        disp('Equivalence is true.')
        
    else
        
        error('Equivalence is false.')

    end
    %--------- Commute also emitter Paulis ------------------------------------                          

    ConvertToCZ         = false;
    pass_X_photons      = true;
    pass_emitter_Paulis = true;

    [New_Circuit_3]=Simplify_Circuit(Circuit_Forward,np,ne,circuitOrder,ConvertToCZ,...
                                               pass_X_photons,pass_emitter_Paulis,...
                                               Init_State_Option,...
                                               monitor_update,pause_time,fignum);

    bool=check_equivalence_Clifford_Circuits(Circuit_Forward,New_Circuit_3,'forward');

    if bool

        disp('Equivalence is true.')
        
    else
        
        error('Equivalence is false.')

    end

    %--------- Commute also emitter Paulis & CNOT->CZ -------------------------

    ConvertToCZ         = true;
    pass_X_photons      = true;
    pass_emitter_Paulis = true;

    [New_Circuit_4]=Simplify_Circuit(Circuit_Forward,np,ne,circuitOrder,ConvertToCZ,...
                                               pass_X_photons,pass_emitter_Paulis,...
                                               Init_State_Option,...
                                               monitor_update,pause_time,fignum);

    bool=check_equivalence_Clifford_Circuits(Circuit_Forward,New_Circuit_4,'forward');

    if bool

        disp('Equivalence is true.')
        
    else
        
        error('Equivalence is false.')

    end

end