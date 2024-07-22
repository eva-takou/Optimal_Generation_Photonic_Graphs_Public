function [CNOTs,T]=Opt_CNOT_cnts_LC_Orbit_RGS_no_isomorphs(n)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 18, 2024
%--------------------------------------------------------------------------
%
%Script to get the optimal CNOT counts for any non-isomorphic graph in the
%LC orbit of an RGS. The optimizer we use is Heuristics #1. The emission
%ordering requires only 2 emitters.
%
%Input: n: # of core nodes of RGS
%Output: CNOTs: Optimal CNOT counts for the any non-isomorph in the LC orbit of an
%               RGS
%            T: Total computational time (s) to find the optimal CNOTs

close all;


node_ordering = [2:2:2*n,1:2:2*n]; %first part core qubits, next part leaf qubits
%Exchange the 2nd to last core qubit with the last leaf qubit

last_leaf            = node_ordering(end);
second_to_last_core  = node_ordering(n-1);
node_ordering(n-1)   = last_leaf;
node_ordering(end)   = second_to_last_core;

AdjLC = Map_Out_RGS_Orbit(n,node_ordering); %Generate the orbit of RGS

for l=1:length(AdjLC)
   
    AdjLC{l}=full(AdjLC{l}); 
    
end

Store_Graphs   = false;
Store_Gates    = false;
Verify_Circuit = false;
return_cond    = true;
BackSubsOption = false;

tic
parfor k=1:length(AdjLC)
    
    temp  = Tableau_Class((AdjLC{k}),'Adjacency');
    temp  = temp.Generation_Circuit_Heu1(1:2*n,Store_Graphs,Store_Gates,...
                                         BackSubsOption,Verify_Circuit,...
                                         return_cond,false,[]);
    
    temp     = temp.Count_emitter_CNOTs;
    CNOTs(k) = temp.Emitter_CNOT_count;            
    
end
T=toc;
%----------- Plot the results ---------------------------------------------
bar(CNOTs,'facecolor',[0.8500 0.3250 0.0980])
xlabel('LC index')
ylabel('$\#$ of emitter CNOTs','interpreter','latex')
set(gcf,'color','w')
set(gca,'fontsize',22,'fontname','Microsoft Sans Serif')
title(['$K_{',num2str(n),'}^{',num2str(n),'}$, $T=$',num2str(T),'(s)'],'interpreter','latex')

end