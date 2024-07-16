function [Tab_Out,Circ_Out,Graphs_Out]=Generation_Circuit_Opt(workingTab,Circuit,graphs,np,ne,n,Store_Graphs,Store_Gates,prune,tryLC,LC_Rounds,LCsTop,BackSubsOption,return_cond)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 27, 2024
%--------------------------------------------------------------------------
%
%Script for finding the circuit to prepare a photonic graph
%state from emitters, by miniming the CNOT cost between emitters. This
%script is used in the brute-force optimization.
%It explores photonic emissions by different emitters, row operations, and
%local complementations. The circuit is traversed in reverse order, to
%convert the target tableau (provided in canonical form) to a product state
%where all qubits start from |0>^{\otimes n}.
%The local complementations are strictly applied after we have started
%consuming away some part of the graph e.g., right after the 2nd TRM, and
%at later steps in the circuit.We further have the option to prune 
%away choices.
%
%Input: workingTab: Current Tableau
%       Circuit: An empty struct with field Circuit.Gate.name and
%       Circuit.Gate.qubit and Circuit.EmCNOTs.
%       graphs: A struct with fields graphs.Adjacency and graphs.identifier
%       np: # of photons
%       ne: # of emitters
%        n: total # of qubits
%       Store_Graphs: true or false to keep track of how the graph changes.
%       Store_Gates: true or false to keep store the gates of the circuit
%       prune: true or false to discard realizations.
%       tryLC: true or false to allow local complementations during the
%       generation.
%       LC_Rounds: 1 or 2 or 3 or 4 regarding up to how many LC sequences
%       we want to go. Example: 1 LC round is only
%       about single nodes v, 2 LC rounds is about v1*v2, v1*v3,... v2*v1
%       etc
%       LCsTop: true or false to enable one round of LC after 2nd TRM
%       BackSubsOption: true or false to enable Back-substitution on the
%       RREF Tableau
%       return_cond: false to inspect all extra conditions for free photon
%       absorption, true for early exit.
%
%Output: Tab_Out: All possible tableaus
%        Circ_Out: All corresponding circuits
%        Graphs_Out: All corresponding graph evolutions
%
%--------  Note: ----------------------------------------------------------
%The emitters have not yet been decoupled for all tableaus, we have
%only finished with consuming all the photons.
%--------------------------------------------------------------------------

level               = np+1; %Call this level because it is related to recursions.
Tab_Out             = {};
Circ_Out            = {};
Graphs_Out          = {};
%------ Initialize empty stacks ------------------------------------------
newTab           = repmat({[]},1,np+1);  
newCirc          = newTab;
newgraphs        = newTab;

trmTab          = newTab;
trmCirc         = newCirc;
trmGraphs       = newgraphs; 
perform_TRM     = true;

%-------------------------------------------------------------------------
while true %Keep looping till we have used up all trmTabs and all newTabs

    photon           = level-1; %level starts from np+1    
    workingTab = RREF(workingTab,n);

    if BackSubsOption

        workingTab = Back_Subs_On_RREF_Tab(workingTab,n,[]);

    end

    h  = height_function(workingTab,n,true,level); %Height function
    dh = h(level)-h(level-1); 

    %-------- TRM stage ---------------------------------------------------
    
    if perform_TRM
        
        if dh<0 %Need TRM

            [tempTab,tempCirc,tempGraphs]=time_reversed_measurement(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates);

            %Try LCs after we have consumed at least 1 photon after TRM (only 1 LC round)
            if photon<np && LCsTop 
                
                Adj0=Get_Adjacency(tempTab);
                
                LC_qubits=[];
                
                for jj=1:n
                   
                    [cond_prod,~]=qubit_in_product(tempTab,n,jj);
                    
                    if ~cond_prod
                       
                        LC_qubits=[LC_qubits,jj];
                        
                    end
                    
                end
                
                Tab0    = tempTab;
                Circ0   = tempCirc;
                Graphs0 = tempGraphs;
                
                tempTab    ={};
                tempCirc   ={};
                tempGraphs ={};
                
                for k=1:length(LC_qubits)
                    
                   v=LC_qubits(k);
                   Nv=Get_Neighborhood(Adj0,v);
                   
                   Tab=Tab0;
                   Circuit=Circ0;
                   Graphs=Graphs0;
                   
                   if length(Nv)>1
                      
                     
                       Tab = Had_Gate(Tab,v,n);
                       Tab = Phase_Gate(Tab,v,n);
                       Tab = Had_Gate(Tab,v,n);

                       Circuit = store_gate_oper(v,'H',Circuit,Store_Gates);  
                       Circuit = store_gate_oper(v,'P',Circuit,Store_Gates);  
                       Circuit = store_gate_oper(v,'H',Circuit,Store_Gates);  

                       for l=1:length(Nv)
                           
                            Tab     = Phase_Gate(Tab,Nv(l),n);
                            Circuit = store_gate_oper(Nv(l),'P',Circuit,Store_Gates);  
                           
                       end
                       
                       if Store_Graphs
                       
                       Graphs  = store_graph_transform(Local_Complement(Adj0,v),...
                                 strcat('After LC_{',num2str(v),'} [After TRM]'),Graphs);
                       end
                       
                       tempTab    = [tempTab,{Tab}];
                       tempCirc   = [tempCirc,{Circuit}];
                       tempGraphs = [tempGraphs,{Graphs}];
                       
                   end
                    
                end
                
            end
            
            
            if ~iscell(tempTab)
                
                %The first ne TRMS need no optimization. We have available emitters we can pick for free.
                
                tempTab    ={tempTab};
                tempCirc   ={tempCirc};
                tempGraphs ={tempGraphs};
                    
            end
                
            trmTab{level}    = [trmTab{level},tempTab];
            trmCirc{level}   = [trmCirc{level},tempCirc];
            trmGraphs{level} = [trmGraphs{level},tempGraphs];

        end
        
    end
    
    %----- FIFO on trmTabs ------------------------------------------------
    if dh<0 %We entered a TRM above so we need to pick out a workingTab to proceed
    
        workingTab = trmTab{level}{1};
        Circuit    = trmCirc{level}{1};
        graphs     = trmGraphs{level}{1};
        
        trmTab{level}(1)    =[];
        trmCirc{level}(1)   =[];
        trmGraphs{level}(1) =[];
    
    else %We didn't enter a TRM above, so we have a workingTab already.
         
        perform_TRM=true; %We need to re-allow TRM for next iterations.
        
    end
    
    %----------- PA step --------------------------------------------------    
    
    [workingTab,Circuit,graphs,discovered_emitter,~]=photon_absorption_WO_CNOT(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates,return_cond);
    
    if ~discovered_emitter 

        [workingTab,Circuit,graphs]=photon_absorption_W_CNOT_Opt(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates,tryLC,LC_Rounds); %Output Tab, circuit and graphs are cells 
        
    else
        workingTab={workingTab};
        Circuit={Circuit};
        graphs={graphs};
        
    end
        
    newTab{level}          = [workingTab,newTab{level}]; %FIFO
    newCirc{level}         = [Circuit,newCirc{level}];        
    newgraphs{level}       = [graphs,newgraphs{level}];
        
    %--------- Moving to next level ---------------------------------------
    
    if photon==1 %We have absorbed the last photon -- store all tableaus of this last level.

        if prune %Discard circuits of current level whose CNOT cnt exceeds the min CNOT cnt.

            
            
            [newTab,newCirc,newgraphs] = prune_procedure(newTab,newCirc,newgraphs,level);            

        end

        L2                       = length(newCirc{level});
        Circ_Out(end+1:end+L2)   = newCirc{level};
        Tab_Out(end+1:end+L2)    = newTab{level};
        Graphs_Out(end+1:end+L2) = newgraphs{level};

        newTab{level}          = [];
        newCirc{level}         = [];
        newgraphs{level}       = [];
        
    end

    %Pop out and remove from list. -- Move to appropriate level.

    if isempty(newTab{level})

        indx = get_next_nonempty_level_newTab(newTab);

        if isempty(indx)   %All tableaus from newTab have been processed.
            
            indx=get_next_nonempty_level_trmTab(trmTab); %Have we used up all trmTabs?
            
            if isempty(indx)
                
                break %Exhausted all possibilities. Exit the loop.
                
            else 
                
                perform_TRM = false; %Turn this off, because we are returning to the same level and we don't want to re-perform TRM.
                level       = indx;  
                
                [workingTab,Circuit,graphs,trmTab,trmCirc,trmGraphs,level]=...
                    process_next_trmTab(trmTab,trmCirc,trmGraphs,level);                
                
                continue %Skip lines below because there are no more newTabs left.
                
            end
            
        end

        level = indx;   
        
    end    

    if ~isempty(newTab{level}) %Pop out the next tableau to process.
        
        if prune %Discard circuits of current level whose CNOT cnt exceeds the min CNOT cnt.

            [newTab,newCirc,newgraphs]=prune_procedure(newTab,newCirc,newgraphs,level);

        end
        
        [workingTab,Circuit,graphs,newTab,newCirc,newgraphs,level]=...
         process_next_newTab(newTab,newCirc,newgraphs,level);
     
        %This level is level-1. We go to photon absorption of next photon.
        
    end    

end

%--- Make sure we have processed all Tableaus -----------------------------

indx1=get_next_nonempty_level_newTab(newTab);
indx2=get_next_nonempty_level_trmTab(trmTab);

if ~isempty(indx1) || ~isempty(indx2)
    
   error('Some realizations have not been processed all the way to the end.') 
    
end

%----------------- Done with exploring cases ------------------------------

%Drop cases if we prune:
if prune

    CNOT_cnt=zeros(1,length(Circ_Out));

    for p=1:length(Circ_Out)

        CNOT_cnt(p)=emitter_CNOTs(Circ_Out{p});

    end

    [minCNOT_cnt,~]=min(CNOT_cnt);

    to_remove = find(CNOT_cnt>minCNOT_cnt);
    
    if length(to_remove)<length(CNOT_cnt)
    
        Tab_Out(to_remove)=[];
        Circ_Out(to_remove)=[];
        Graphs_Out(to_remove)=[];
        
    end
    
end

if  isempty(Tab_Out)
    
   error('We have a bug, we probably generated circuits but discarded all of them in the process.') 
   
end

end


function [newTab,newCirc,newgraphs]=prune_procedure(newTab,newCirc,newgraphs,level)
%Discard circuits of current level. If at the current level a particular
%Circuit has a min value of CNOT count = s, and the other Circuits at the
%current level have a min value of CNOT count > s, then we discard those
%Tableaus and circuits, and we do not process them till the end.

CNOT_cnt = zeros(1,length(newTab{level})); %re-initialize.
            
for p=1:length(newTab{level})

    CNOT_cnt(p)=emitter_CNOTs(newCirc{level}{p});

end

[minCNOT,~]     = min(CNOT_cnt);
CNOT_exceed_min = find(CNOT_cnt>minCNOT);

if length(CNOT_exceed_min)<length(CNOT_cnt)

    newTab{level}(CNOT_exceed_min)          = [];
    newCirc{level}(CNOT_exceed_min)         = [];
    newgraphs{level}(CNOT_exceed_min)       = [];
    
end
        
%This is optional: We can prune away more cases:

%Lmax=25; %40 mins for 500 graphs, 26.9% np=8 (search on 2 methods)
%Lmax=10; %4.5 mins for 2e3 graphs, 19% np=7 (search on 2 methods)
%Lmax=15; %10.5 mins for 2e3 graphs, 21% np=7 (search on 2 methods)

% Lmax=15;  %4.5 mins for 2e3 graphs, 20.96% np=7 (search on 1 method-extra PA + BackSubs)
% Lmax=20;  %8.67 mins for 2e3 graphs, 21.58% np=7 (search on 1 method-extra PA + BackSubs)
% Lmax=25;  %10 mins for 2e3 graphs, 21.75% np=7 (search on 1 method-extra PA + BackSubs)
% Lmax=30;  %8.32  mins for 2e3 graphs,  21.79% np=7 (search on 1 method-extra PA + BackSubs)
% Lmax=35;  %8.7  mins for 2e3 graphs,  21.79% np=7 (search on 1 method-extra PA + BackSubs)

% Lmax=10;    %2.86 mins for 500 graphs, 24.14% np=8 (search on 1 method-extra PA + BackSubs)
% Lmax=15;    %12.35 mins for 500 graphs, 26.1% np=8 (search on 1 method-extra PA + BackSubs)
% Lmax=20;    %25.72 mins for 500 graphs, 27.31% np=8 (search on 1 method-extra PA + BackSubs)
% Lmax=25;    %30 mins for 500 graphs, 27.69% np=8 (search on 1 method-extra PA + BackSubs)
Lmax=30;    %30.5 mins for 500 graphs, 27.8593% np=8 (search on 1 method-extra PA + BackSubs)

if length(newTab{level})>Lmax
   
    newTab{level}(Lmax+1:end)=[];
    newCirc{level}(Lmax+1:end)=[];
    newgraphs{level}(Lmax+1:end)=[];
    
end

end


function indx=get_next_nonempty_level_newTab(newTab)

indx=[];
for jj=1:length(newTab)  %Find the next non-empty level

    if ~isempty(newTab{jj})

        indx=jj;
        break

    end

end

end

function indx=get_next_nonempty_level_trmTab(trmTab)

cond=false;
for jj=1:length(trmTab)  %Find the next non-empty level

    if ~isempty(trmTab{jj})

        indx=jj;
        cond=true;
        break

    end

end 

if ~cond
   indx=[]; 
end


end


function [workingTab,Circuit,graphs,newTab,newCirc,newgraphs,level]=...
         process_next_newTab(newTab,newCirc,newgraphs,level)

workingTab              = newTab{level}{1};
Circuit                 = newCirc{level}{1};
graphs                  = newgraphs{level}{1}; 

newTab{level}(1)          = [];    %FIFO
newCirc{level}(1)         = [];
newgraphs{level}(1)       = []; 
level                     = level-1; %Get the tableau and go to photon absorption of next photon.


end


function [workingTab,Circuit,graphs,trmTab,trmCirc,trmgraphs,level]=...
         process_next_trmTab(trmTab,trmCirc,trmgraphs,level)


workingTab              = trmTab{level}{1};
Circuit                 = trmCirc{level}{1};
graphs                  = trmgraphs{level}{1}; 

trmTab{level}(1)          = [];    %FIFO
trmCirc{level}(1)         = [];
trmgraphs{level}(1)       = []; 

%Do not move one level down, because we are not done with the photon
%absorption of the current photon.

end