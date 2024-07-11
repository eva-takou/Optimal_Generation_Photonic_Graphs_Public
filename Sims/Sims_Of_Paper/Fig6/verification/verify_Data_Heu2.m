function verify_Data_Heu2(iterMax,minK,maxK)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 21, 2024
%--------------------------------------------------------------------------
%
%Run again the optimization to verify a subset of the data.
%
%Input: iterMax: number from 1 till 500 to pick subset of Adjacencies
%       minK: index from 1-8 to pick which starting point from
%       np=[6,8,10,12,18,26,30,40] to start from
%       maxK: index from 1-8 to pick the final range of np


load('optimized_data_heu1.mat','Adj')
load('optimized_data_heu1.mat','CNOT_Naive')
clearvars -except Adj CNOT_Naive iterMax minK maxK

load('opt_data_heu_2.mat','CNOT_Best')
clearvars -except CNOT_Naive minK maxK iterMax Adj CNOT_Best

Store_Graphs    = false;
Store_Gates     = false;
Verify_Circuit  = false;
EXTRA_OPT_LEVEL = true;
emitter_cutoff0 = 5;
future_step     = 2; 
recurse_further = true;
nrange          = [6,8,10,12,18,26,30,40];

parfor iter=1:iterMax
    
    
    for k=minK:maxK %nmin:nstep:nmax
        
        n=nrange(k);
        temp=Tableau_Class(Adj{iter,n},'Adjacency');
        
        
        if k<=5
        
            temp=temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,false,Verify_Circuit,EXTRA_OPT_LEVEL,false,...
                                              emitter_cutoff0,future_step,recurse_further);
                                      
        else
            
            temp=temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,false,Verify_Circuit,EXTRA_OPT_LEVEL,false,...
                                              emitter_cutoff0,future_step,recurse_further,false);
        end
        
        temp                       = temp.Count_emitter_CNOTs;
        CNOT_Heu2_Alt_2_V1(iter,k) = temp.Emitter_CNOT_count;
        
        if k<=5
        
            temp=temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,true,Verify_Circuit,EXTRA_OPT_LEVEL,false,...
                                              emitter_cutoff0,future_step,recurse_further);
                                      
        else
            
            temp=temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,true,Verify_Circuit,EXTRA_OPT_LEVEL,false,...
                                              emitter_cutoff0,future_step,recurse_further,false);
            
        end
        
        
        temp                       = temp.Count_emitter_CNOTs;
        CNOT_Heu2_Alt_2_V2(iter,k) = temp.Emitter_CNOT_count;
        
        if k<=5
            temp=temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,false,Verify_Circuit,EXTRA_OPT_LEVEL,true,...
                                              emitter_cutoff0,future_step,recurse_further);
                                      
        else
            
            temp=temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,false,Verify_Circuit,EXTRA_OPT_LEVEL,true,...
                                              emitter_cutoff0,future_step,recurse_further,false);
            
        end
        
        temp                       = temp.Count_emitter_CNOTs;
        CNOT_Heu2_Alt_2_V3(iter,k) = temp.Emitter_CNOT_count;
        
        
    end
    
end

CNOT_Heu2_Alt_2_temp                      = zeros(iterMax,max(nrange(minK:maxK)));
CNOT_Heu2_Alt_2_temp(:,nrange(minK:maxK)) = CNOT_Heu2_Alt_2_V2(:,minK:maxK);
CNOT_Heu2_Alt_2_V2                        = CNOT_Heu2_Alt_2_temp;

CNOT_Heu2_Alt_2_temp                      = zeros(iterMax,max(nrange(minK:maxK)));
CNOT_Heu2_Alt_2_temp(:,nrange(minK:maxK)) = CNOT_Heu2_Alt_2_V3(:,minK:maxK);
CNOT_Heu2_Alt_2_V3                        = CNOT_Heu2_Alt_2_temp;

CNOT_Heu2_Alt_2_temp                      = zeros(iterMax,max(nrange(minK:maxK)));
CNOT_Heu2_Alt_2_temp(:,nrange(minK:maxK)) = CNOT_Heu2_Alt_2_V1(:,minK:maxK);
CNOT_Heu2_Alt_2_V1                        = CNOT_Heu2_Alt_2_temp;



for iter=1:iterMax
    
    for k=minK:maxK   
        n = nrange(k);
        
        CNOT_Best_Verify(iter,n) = min([CNOT_Heu2_Alt_2_V1(iter,n),CNOT_Heu2_Alt_2_V2(iter,n),...
            CNOT_Heu2_Alt_2_V3(iter,n),CNOT_Naive(iter,n)]);
        
    end
    
end


if ~all(all(CNOT_Best_Verify(1:iterMax,nrange(minK:maxK))==CNOT_Best(1:iterMax,nrange(minK:maxK))))
    
   error('Incorrect evaluation.') 
    
end


end