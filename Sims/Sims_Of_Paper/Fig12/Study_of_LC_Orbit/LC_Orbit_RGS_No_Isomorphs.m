%Get CNOT counts for any non-isomorph in the LC orbit of an RGS, with
%optimal emission ordering.

clearvars;
close all;
clc;

n             = 100; %Number of core qubits
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


%% Get CNOT counts
Store_Graphs   = false;
Store_Gates    = false;
Verify_Circuit = false;
return_cond    = true;
BackSubsOption = false;

tic
parfor k=1:length(AdjLC)
    
    temp  = Tableau_Class((AdjLC{k}),'Adjacency');
    temp  = temp.Generation_Circuit_Heu1(1:2*n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond);
    
    temp     = temp.Count_emitter_CNOTs;
    CNOTs(k) = temp.Emitter_CNOT_count;            
    
end
T=toc;


%% Plot the results

bar(CNOTs,'facecolor',[0.8500 0.3250 0.0980])
xlabel('LC index')
ylabel('$\#$ of emitter CNOTs','interpreter','latex')
set(gcf,'color','w')
set(gca,'fontsize',22,'fontname','Microsoft Sans Serif')
title(['$K_{',num2str(n),'}^{',num2str(n),'}$, $T=$',num2str(T),'(s)'],'interpreter','latex')

