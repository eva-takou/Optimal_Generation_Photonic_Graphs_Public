function [CNOTs,color,legs]=Optimize_Single_Orbit(orbit_index,Opt_ID)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 22, 2024
%--------------------------------------------------------------------------
%
%Subroutine to optimize the emitter CNOT counts using the Naive, Heuristics
%#1, Heuristics #2, or Bruteforce optimizers, for all n=6 order graphs.
%
%Inputs: orbit_index: A number in [1,312] corresponding to the LC family
%                     index
%        Opt_ID: A number in [0,10] to choose the optimizer.
%
%The optimizers based on Opt_ID are listed below:      
%
%
%Opt_ID: 0 Naive: No Back-Subs, no test for PA
%Opt_ID: 1 Heur 1: No Back-Subs, w/refined test for PA
%Opt_ID: 2 Heur 1: W Back-Subs, w/refined test for PA
%Opt_ID: 3 Heur 2: No Back-Subs, w/ refined test for PA
%Opt_ID: 4 Heur 2: W Back-Subs, w/ refined test for PA
%-------------------------------------------------------------
%Opt_ID: 5 Brute-force, prune on, no LCs
%Opt_ID: 6 Brute-force, prune on, 1 LC Round (no LC on top)
%Opt_ID: 7 Brute-force, prune on, 2 LC Round (no LC on top)
%------------------------------------------------------------
%Opt_ID: 8 Brute-force, prune on, 1 LC Round (w LC on top)
%Opt_ID: 9 Brute-force, prune on, 2 LC Round (w LC on top)
%Opt_ID: 10 Brute-force, prune on, 3 LC Round (w LC on top)



load('n_6_orbit.mat','Adj_non_LC')
Adj0   = Adj_non_LC{orbit_index};     %Representative of LC family
n      = 6;
allAdj = Map_Out_Orbit(Adj0,'prune'); %LC orbit of Adj0, excluding isomorphs
    
Store_Graphs    = false;
Store_Gates     = false;
Verify_Circuit  = false;
BackSubsOption  = false;
prune           = true;     %Option for the brute-force optimizer

switch Opt_ID
    
    case 0 %Naive
        
        return_cond=true;
        
        parfor jj=1:length(allAdj)
        
            temp=Tableau_Class(full(allAdj{jj}),'Adjacency');
            temp=temp.Generation_Circuit(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond);
            temp=temp.Count_emitter_CNOTs;

            CNOTs(jj)=temp.Emitter_CNOT_count;

        end
        
        legs={'Naive'};
        color='k';
        
        
    case 1 %Heuristics 1: No Back-Subs, w/refined test for PA
        
        return_cond=false;
        
        parfor jj=1:length(allAdj)
        
            temp=Tableau_Class(full(allAdj{jj}),'Adjacency');    
            temp=temp.Generation_Circuit_Heu1(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond);
            temp=temp.Count_emitter_CNOTs;
            CNOTs(jj)=temp.Emitter_CNOT_count;

        end
        
        legs={'Heu $\#1$'};
        color=[0.8500 0.3250 0.0980];
        
    case 2 %Heuristics 1: W Back-Subs, w/refined test for PA
        
        return_cond=false;
        BackSubsOption=true;
        parfor jj=1:length(allAdj)
        
            temp=Tableau_Class(full(allAdj{jj}),'Adjacency');    
            temp=temp.Generation_Circuit_Heu1(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond);
            temp=temp.Count_emitter_CNOTs;
            CNOTs(jj)=temp.Emitter_CNOT_count;

        end
        
        legs={'Heu $\#1$'};
        color=[0.8500 0.3250 0.0980];
         
        
    case 3 %Heur 2: No Back-Subs, w/ refined test for PA

        return_cond     = false;
        EXTRA_OPT_LEVEL = true;
        emitter_cutoff0 = 4;
        future_step     = 4;
        recurse_further = true;
        
        parfor jj=1:length(allAdj)
        
            temp=Tableau_Class(full(allAdj{jj}),'Adjacency');
            temp=temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,EXTRA_OPT_LEVEL,...
                                              return_cond,emitter_cutoff0,future_step,recurse_further);
            temp=temp.Count_emitter_CNOTs;
            CNOTs(jj)=temp.Emitter_CNOT_count;

        end
        
        legs={'Heu $\#2$'};
        color='c';
        
    case 4 %Heur 2: W Back-Subs, w/ refined test for PA
        
        BackSubsOption  = true;
        return_cond     = false;
        EXTRA_OPT_LEVEL = true;
        emitter_cutoff0 = 4;
        future_step     = 4;
        recurse_further = true;
        
        parfor jj=1:length(allAdj)
        
            temp=Tableau_Class(full(allAdj{jj}),'Adjacency');
            temp=temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,EXTRA_OPT_LEVEL,...
                                              return_cond,emitter_cutoff0,future_step,recurse_further);
            temp=temp.Count_emitter_CNOTs;
            CNOTs(jj)=temp.Emitter_CNOT_count;

        end
        
        legs={'Heu $\#2$'};
        color='c';        
        
    case 5
        
        tryLC=false;
        LCsTop=false;
        LC_Rounds=[];
        return_cond=true;
        BackSubsOption=false;
        
        parfor jj=1:length(allAdj)
            
            temp  = Tableau_Class(full(allAdj{jj}),'Adjacency');
            temp  = temp.Optimize_Generation_Circuit(1:n,Store_Graphs,Store_Gates,...
                                                     prune,tryLC,LC_Rounds,Verify_Circuit,LCsTop,...
                                                     BackSubsOption,return_cond);
            CNOTs(jj) = temp.Emitter_CNOT_count;
            
        end
        
        legs={'Brute-force (No LCs)'};
        color=[0.9290 0.6940 0.1250];
        
    case 6

        tryLC=true;
        LC_Rounds=1;
        LCsTop=false;
        return_cond=true;
        BackSubsOption=false;        
        
        parfor jj=1:length(allAdj)
            
            
            temp  = Tableau_Class(full(allAdj{jj}),'Adjacency');
            temp  = temp.Optimize_Generation_Circuit(1:n,Store_Graphs,Store_Gates,prune,...
                                                     tryLC,LC_Rounds,Verify_Circuit,LCsTop,...
                                                     BackSubsOption,return_cond);
            CNOTs(jj) = temp.Emitter_CNOT_count;
            
        end
        
        legs={'Brute-force (1 LC Round)'};
        color=[0.9290 0.6940 0.1250];
        
    case 7
        
        tryLC=true;
        LC_Rounds=2;
        LCsTop=false;
        BackSubsOption=false;
        return_cond=true;
        
        parfor jj=1:length(allAdj)
            
            temp  = Tableau_Class(full(allAdj{jj}),'Adjacency');
            temp  = temp.Optimize_Generation_Circuit(1:n,Store_Graphs,Store_Gates,prune,...
                                                     tryLC,LC_Rounds,Verify_Circuit,LCsTop,...
                                                     BackSubsOption,return_cond);
            CNOTs(jj) = temp.Emitter_CNOT_count;
            
        end
        
        legs={'Brute-force (2 LC Rounds)'};
        color=[0.9290 0.6940 0.1250];
        
        
    case 8
        
        tryLC=true;
        LC_Rounds=2;
        LCsTop=false;
        prune=false;
        BackSubsOption=false;
        return_cond=true;
        
        parfor jj=1:length(allAdj)
            
            temp  = Tableau_Class(full(allAdj{jj}),'Adjacency');
            temp  = temp.Optimize_Generation_Circuit(1:n,Store_Graphs,Store_Gates,prune,...
                                                     tryLC,LC_Rounds,Verify_Circuit,LCsTop,...
                                                     BackSubsOption,return_cond);
            CNOTs(jj) = temp.Emitter_CNOT_count;
            
        end
        
        legs={'Brute-force (2 LC Rounds, no prune)'};
        color=[0.9290 0.6940 0.1250];        
        
    case 9
        
        tryLC=true;
        LC_Rounds=1;
        LCsTop=true;
        BackSubsOption=false;
        return_cond=true;
        
        parfor jj=1:length(allAdj)
            
            temp  = Tableau_Class(full(allAdj{jj}),'Adjacency');
            temp  = temp.Optimize_Generation_Circuit(1:n,Store_Graphs,Store_Gates,prune,...
                                                     tryLC,LC_Rounds,Verify_Circuit,LCsTop,...
                                                     BackSubsOption,return_cond);
            CNOTs(jj) = temp.Emitter_CNOT_count;
            
        end
    
        legs={'Brute-force (1 LC Rounds w top LCs)'};
        color=[0.9290 0.6940 0.1250];
     
    case 10
        
        tryLC=true;
        LC_Rounds=1;
        LCsTop=true;
        prune=false;
        
        BackSubsOption=false;
        return_cond=true;
        
        parfor jj=1:length(allAdj)
            
            temp  = Tableau_Class(full(allAdj{jj}),'Adjacency');
            temp  = temp.Optimize_Generation_Circuit(1:n,Store_Graphs,Store_Gates,prune,...
                                                     tryLC,LC_Rounds,Verify_Circuit,LCsTop,...
                                                     BackSubsOption,return_cond);
            CNOTs(jj) = temp.Emitter_CNOT_count;
            
        end
    
        legs={'Brute-force (1 LC Rounds w top LCs, no prune)'};
        color=[0.9290 0.6940 0.1250];
        
        
    case 11
        
        tryLC=true;
        LC_Rounds=2;
        LCsTop=true;
        BackSubsOption=false;
        return_cond=true;
        
        parfor jj=1:length(allAdj)
            
            temp  = Tableau_Class(full(allAdj{jj}),'Adjacency');
            temp  = temp.Optimize_Generation_Circuit(1:n,Store_Graphs,Store_Gates,prune,...
                                                     tryLC,LC_Rounds,Verify_Circuit,LCsTop,...
                                                     BackSubsOption,return_cond);
            CNOTs(jj) = temp.Emitter_CNOT_count;
            
        end
        
        legs={'Brute-force (2 LC Rounds w top LCs)'};
        color=[0.9290 0.6940 0.1250];

    case 12
        
        tryLC=true;
        LC_Rounds=3;
        LCsTop=true;
        BackSubsOption=false;
        return_cond=true;
        
        parfor jj=1:length(allAdj)
            
            temp  = Tableau_Class(full(allAdj{jj}),'Adjacency');
            temp  = temp.Optimize_Generation_Circuit(1:n,Store_Graphs,Store_Gates,prune,...
                                                     tryLC,LC_Rounds,Verify_Circuit,LCsTop,...
                                                     BackSubsOption,return_cond);
            CNOTs(jj) = temp.Emitter_CNOT_count;
            
        end        
        
        legs={'Brute-force (3 LC Rounds w top LCs)'};
        color=[0.9290 0.6940 0.1250];
end

    


end