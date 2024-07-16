%Test to verify the quantum circuits obtained by the Naive method.

clearvars;
close all;
clc;

Store_Graphs   = false;
Store_Gates    = true;
BackSubsOption = false;
Verify_Circuit = true;
return_cond    = true;

np      = 8;
iterMax = 1e3;

for iter = 1:iterMax
   
    Adj{iter} = create_random_graph(np);
    
end

parfor iter = 1:iterMax
    
    temp = Tableau_Class(Adj{iter},'Adjacency');
    Target_Tableau = temp.Tableau;
    temp = temp.Generation_Circuit(1:np,Store_Graphs,Store_Gates,BackSubsOption,...
                                 Verify_Circuit,return_cond);
    Circ = temp.Photonic_Generation_Gate_Sequence;

    ne = temp.Emitters;
    n  = np+ne;

    encountered_warning = Verify_Circuit_Forward_Order(Circ,Adj{iter},ne,'backward');
    
    if encountered_warning
    
        error('All phases should be (+).')
        
    end
    
    
end