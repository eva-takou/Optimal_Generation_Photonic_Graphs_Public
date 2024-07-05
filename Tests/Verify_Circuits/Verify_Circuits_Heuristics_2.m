%Test to verify the quantum circuits obtained by the Heuristics #2 method.

clearvars; close all; clc; warning('off')

Store_Graphs   = false;
Store_Gates    = true;
BackSubsOption = true;
Verify_Circuit = true;
return_cond    = false;

EXTRA_OPT_LEVEL = true;
emitter_cutoff0 = 3;
future_step     = 3;
recurse_further = true;

np      = 15;
iterMax = 500;

for iter = 1:iterMax
   
    Adj{iter} = create_random_graph(np);
    
end

for iter = 1:iterMax
    
    temp = Tableau_Class(Adj{iter},'Adjacency');
    Target_Tableau = temp.Tableau;
    temp = temp.Generation_Circuit_Heu2(1:np,Store_Graphs,Store_Gates,...
                                        BackSubsOption,Verify_Circuit,...
                                        EXTRA_OPT_LEVEL,return_cond,...
                                        emitter_cutoff0,future_step,...
                                        recurse_further);
    
    Circ = temp.Photonic_Generation_Gate_Sequence;

    ne = temp.Emitters;
    n  = np+ne;

    
    Verify_Quantum_Circuit(Circ,n,ne,Target_Tableau)
    
    encountered_warning = Verify_Circuit_Forward_Order(Circ,Adj{iter},ne,'backward');
    
    if encountered_warning
    
        Circ      = fix_potential_phases_forward_circuit(Circ,Adj{iter},ne,'backward');
        
    end
    
    message_2 = Verify_Circuit_Forward_Order(Circ,Adj{iter},ne,'backward');
    
    if message_2
       error('We did not fix phases') 
    end    
end