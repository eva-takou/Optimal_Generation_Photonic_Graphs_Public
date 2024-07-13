function [Adj,CNOT_Naive,CNOT_Best,Reduction]=...
      CNOT_Scaling_Naive_vs_Heuristics_2_single_np(n,Nsamples,Option)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 28, 2024
%--------------------------------------------------------------------------
%
%Script to create Histograms for % Reduction of emitter-emitter CNOTs
%obtained by the Heuristics #2 method (reduction is compared to Naive
%approach).
%
%Input: n: # of photons in the graph
%       Nsamples: # of iterations to collect statistics
%       Option: 'New_Run' to generate new data, or 'Old_Data' to run again
%       the results of the paper.
%Output: Adj: A cell array contained the adjacency matrices
%        CNOT_Naive: Emitter CNOT counts obtained by the Naive method
%        CNOT_Best: Min emitter CNOT counts for each adjacency obtained by 2
%        variants of Heuristics #2
%        Reduction: Percentage reduction of emitter CNOTs

close all;

switch Option
    
    case 'New_Run'
        
        parfor iter=1:Nsamples

            Adj{iter}=full(create_random_graph(n));

        end        
        
    case 'Old_Data'
        
        if n==9
            
            load('np_9.mat','Adj')
            clearvars -except Adj n Nsamples
            Nsamples = length(Adj);
        
        elseif n==15

            load('np_15.mat','Adj')
            clearvars -except Adj n 
            Nsamples = length(Adj);
            
        elseif n==20
            
            load('np_20.mat','Adj')
            clearvars -except Adj n 
            Nsamples = length(Adj);
            
        elseif n==30
            
            load('np_30.mat','Adj')
            clearvars -except Adj n
            Nsamples = length(Adj);
            
        else
            error('Do not have stored data for other n.')
        end
        
end

  
Store_Graphs   = false;
Store_Gates    = false;
Verify_Circuit = false;

if n==9

    emitter_cutoff0 = 5;
    future_step     = 5;  
    recurse_further = true;
    EXTRA_OPT_LEVEL = true;
     
    
elseif n==15

    emitter_cutoff0 = 4; 
    future_step     = 4;  
    recurse_further = true;
    EXTRA_OPT_LEVEL = true;    
    
elseif n==20
    
    emitter_cutoff0 = 4;
    future_step     = 4;
    recurse_further = true;
    EXTRA_OPT_LEVEL = true;    
    
elseif n==30
    
    emitter_cutoff0 = 4;
    future_step     = 2;
    recurse_further = true;
    EXTRA_OPT_LEVEL = true;    
    
elseif n==50
    
    emitter_cutoff0 = 4;
    future_step     = 2;
    recurse_further = false;
    EXTRA_OPT_LEVEL = true;    
    
    
elseif n==60
    
    emitter_cutoff0 = 5;
    future_step     = 2;
    recurse_further = false;
    EXTRA_OPT_LEVEL = true;    
    
elseif n==100
    
    emitter_cutoff0 = 3;
    future_step     = 3;
    recurse_further = false;
    EXTRA_OPT_LEVEL = true;   

end




parfor iter=1:Nsamples
    
   temp      = Tableau_Class(Adj{iter},'Adjacency');
   
   %------------ Naive ---------------------------------------------------
   BackSubsOption = false;
   return_cond    = true;

   temp=temp.Generation_Circuit(1:n,Store_Graphs,Store_Gates,...
                                BackSubsOption,Verify_Circuit,return_cond);
   
   temp             = temp.Count_emitter_CNOTs;
   CNOT_Naive(iter) = temp.Emitter_CNOT_count;
   
   
   %------------ 1st variant of Heu 2 -------------------------------------
   BackSubsOption = false;
   return_cond    = true;
   
   
   temp=temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,BackSubsOption,...
                                     Verify_Circuit,EXTRA_OPT_LEVEL,return_cond,...
                                     emitter_cutoff0,future_step,recurse_further) ;
    
   temp             = temp.Count_emitter_CNOTs;
   CNOT_Heu2_V1(iter) = temp.Emitter_CNOT_count;
                                 
   %------------ 2nd variant of Heu 2 ------------------------------------- 
   BackSubsOption = true;
   return_cond    = false;
   
   temp=temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,BackSubsOption,...
                                     Verify_Circuit,EXTRA_OPT_LEVEL,return_cond,...
                                     emitter_cutoff0,future_step,recurse_further) ;
   
   temp               = temp.Count_emitter_CNOTs;
   CNOT_Heu2_V2(iter) = temp.Emitter_CNOT_count;
   
   %------------ 3rd variant of Heu 2 ------------------------------------- 
   BackSubsOption = false;
   return_cond    = false;
   
   temp=temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,BackSubsOption,...
                                     Verify_Circuit,EXTRA_OPT_LEVEL,return_cond,...
                                     emitter_cutoff0,future_step,recurse_further) ;
   
   temp               = temp.Count_emitter_CNOTs;
   CNOT_Heu2_V3(iter) = temp.Emitter_CNOT_count;   
   
end

CNOT_Best=zeros(1,Nsamples);

for iter=1:Nsamples
    
   CNOT_Best(iter) = min([CNOT_Heu2_V1(iter),CNOT_Heu2_V2(iter),...
                         CNOT_Heu2_V3(iter),CNOT_Naive(iter)]);
    
end


Reduction = (CNOT_Naive-CNOT_Best)./CNOT_Naive*100;


histogram(Reduction) %,'Normalization','probability'
ylabel('$\#$ of instances','interpreter','latex')
xlabel('Reduction $\%$','interpreter','latex')
set(gcf,'color','w')
set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')


A1 = strcat('$n_p=$',num2str(n));
A2 = strcat(', $\#$ of samples:~',num2str(Nsamples));
A12 = strcat(A1,A2);

B1 = strcat('emitter cutoff:~',num2str(emitter_cutoff0));
B2 = strcat(', future step:~',num2str(future_step));
B12 = strcat(B1,B2);

title([{A12,B12,}],'interpreter','latex')


end