function [Adj,CNOT_Naive,CNOT_Best,Reduction]=...
      CNOT_Scaling_Naive_vs_Heuristics_1_single_np(n,Nsamples,Option)

%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 25, 2024
%--------------------------------------------------------------------------
%
%Script to create Histograms for % Reduction of emitter-emitter CNOTs
%obtained by the Heuristics #1 method (reduction is compared to Naive
%approach).
%
%Input: n: # of photons in the graph
%       Nsamples: # of iterations to collect statistics
%       Option: 'New_Run' to generate new data, or 'Old_Data' to run again
%       the results of the paper.
%Output: Adj: A cell array contained the adjacency matrices
%        CNOT_Naive: Emitter CNOT counts obtained by the Naive method
%        CNOT_Best: Min emitter CNOT counts for each adjacency obtained by 2
%        variants of Heuristics #1
%        Reduction: Percentage reduction of emitter CNOTs
  
switch Option
    
    case 'New_Run'
        
        parfor iter=1:Nsamples

            Adj{iter}=full(create_random_graph(n));

        end        
        
    case 'Old_Data'
        
        if n==9
            
            load('1e5_samples_np_9.mat','Adj')
            clearvars -except Adj n Nsamples
            Nsamples = length(Adj);
            
        elseif n==15

            load('1e3_samples_np_15.mat','Adj')
            clearvars -except Adj n 
            Nsamples = length(Adj);
            
        elseif n==40
            
            load('1e3_samples_np_40.mat','Adj')
            clearvars -except Adj n 
            Nsamples = length(Adj);
            
        elseif n==70
            
            load('100_samples_np_70.mat','Adj')
            clearvars -except Adj n
            Nsamples = length(Adj);
            
        else
            error('Do not have stored data for other n.')
        end
        
end

Store_Graphs   = false;
Store_Gates    = false;
Verify_Circuit = false;

parfor iter=1:Nsamples
    
    disp(['iter=',num2str(iter)])
    temp = Tableau_Class(Adj{iter},'Adjacency');

    %----------- Naive ---------------------
    BackSubsOption = false;
    return_cond    = true;

    temp = temp.Generation_Circuit(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond);
   
    temp             = temp.Count_emitter_CNOTs;
    CNOT_Naive(iter) = temp.Emitter_CNOT_count;
   
    %----------- 1st variant of Heu1 ---------------------
  
    BackSubsOption = false;
    return_cond    = true;
   
   
    temp = temp.Generation_Circuit_Heu1(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond);
    
    temp             = temp.Count_emitter_CNOTs;
    CNOT_Heu1_V1(iter) = temp.Emitter_CNOT_count;
                                 
    %----------- 2nd variant of Heu1 ---------------------
   
    BackSubsOption = true;
    return_cond    = false;
   
    temp = temp.Generation_Circuit_Heu1(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond); 
   
    temp               = temp.Count_emitter_CNOTs;
    CNOT_Heu1_V2(iter) = temp.Emitter_CNOT_count;
   
end

CNOT_Best = zeros(1,Nsamples);

for iter=1:Nsamples
    
   CNOT_Best(iter) = min([CNOT_Heu1_V1(iter),CNOT_Heu1_V2(iter),...
                          CNOT_Naive(iter)]);
    
end

Reduction = (CNOT_Naive-CNOT_Best)./CNOT_Naive*100;
%---------- Plot the results ----------------------------------------------

close all
histogram(Reduction) %,'Normalization','probability'
ylabel('$\#$ of instances','interpreter','latex')
xlabel('Reduction $\%$','interpreter','latex')
set(gcf,'color','w')
set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')


A1 = strcat('$n_p=$',num2str(n));
A2 = strcat(', $\#$ of samples:~',num2str(Nsamples));
A12 = strcat(A1,A2);

title([{A12}],'interpreter','latex')

end