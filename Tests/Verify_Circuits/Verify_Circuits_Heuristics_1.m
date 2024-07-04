%Test to verify the quantum circuits obtained by the Heuristics #1 method.

clearvars;
close all
clc;

Store_Graphs   = false;
Store_Gates    = true;
BackSubsOption = true;
Verify_Circuit = true;
return_cond    = false;

np      = 15;
iterMax = 500;

for iter = 1:iterMax
   
    Adj{iter} = create_random_graph(np);
    
end

for iter = 1:iterMax
    
    temp = Tableau_Class(Adj{iter},'Adjacency');
    Target_Tableau = temp.Tableau;
    temp = temp.Generation_Circuit_Heu1(1:np,Store_Graphs,Store_Gates,...
                                        BackSubsOption,Verify_Circuit,...
                                        return_cond);
    
    Circ = temp.Photonic_Generation_Gate_Sequence;

    ne = temp.Emitters;
    n  = np+ne;

    
    Verify_Quantum_Circuit(Circ,n,ne,Target_Tableau)
    Verify_Circuit_Forward_Order(Circ,Adj{iter},ne,'backward')
    
end