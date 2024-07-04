%Test to verify the quantum circuits obtained by the Bruteforce method.

clearvars; close all; clc; warning('off')

Store_Graphs   = false;
Store_Gates    = true;
BackSubsOption = true;
Verify_Circuit = true;
return_cond    = false;


prune     = false;
LCsTop    = false;
tryLC     = true;
LC_Rounds = 1;

np      = 7;
iterMax = 20;

for iter = 1:iterMax
   
    Adj{iter} = create_random_graph(np);
    
end

for iter = 1:iterMax
    
    temp = Tableau_Class(Adj{iter},'Adjacency');
    Target_Tableau = temp.Tableau;
    temp = temp.Optimize_Generation_Circuit(1:np,Store_Graphs,Store_Gates,...
                                            prune,tryLC,LC_Rounds,...
                                            Verify_Circuit,LCsTop,...
                                            BackSubsOption,return_cond); 
        
    Circ = temp.Photonic_Generation_Gate_Sequence;

    ne = temp.Emitters;
    n  = np+ne;

    
    Verify_Quantum_Circuit(Circ,n,ne,Target_Tableau)
    message_1 = Verify_Circuit_Forward_Order(Circ,Adj{iter},ne,'backward');
    
    Circ=fix_potential_phases_forward_circuit(Circ,Adj{iter},ne,'backward');
    
    message_2 = Verify_Circuit_Forward_Order(Circ,Adj{iter},ne,'backward');
    
    if message_2
       error('We did not fix phases') 
    end    
end