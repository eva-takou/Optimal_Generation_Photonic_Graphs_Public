function [Tab,Circuit,graphs]=disentangle_all_emitters(Tab,np,ne,Circuit,graphs,Store_Graphs,Store_Gates,BackSubs)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 14, 2024
%--------------------------------------------------------------------------
%
%Function to disentangle the emitters after having absorbed all the
%photons.
%Inputs: Tab: Tableau
%        np: # of photons
%        ne: # of emitters
%        Circuit: The circuit that generates the target graph state
%        Store_Graphs: true or false to store the progress on the graph
%        level (store graph after two-qubit gate updates)
%        Store_Gates: true or false to store the gates.
%        BackSubs: Option to perform or not back-substitution on the
%        Tableau
%Output: Tab: The updated tableau
%        Circuit: The updated circuit
%        graphs: the updated graphs
%
%#TODO#: Think of a more clever way for the decoupling.
%        Maybe we can test some LC graphs and reach one
%        with minimal # of edges.
%        Or maybe we can apply the parallel elimination
%        technique.

n = np+ne;

%Check that all photons have been absorbed already:
for jj=1:np
   
    [cond_prod,~]=qubit_in_product(Tab,np+ne,jj);
    
    if ~cond_prod
        
       error(['Photon ',num2str(jj),' has not been absorbed.']) 
       
    end
    
end

disentangled_em=[];

while true
    
   [Tab,flag,Circuit,graphs,disentangled_em]=disentangle_two_emitters(Tab,np,ne,Circuit,graphs,Store_Graphs,Store_Gates,disentangled_em,BackSubs);
   
   if flag %flag is true when all the emitters are disentangled.
       
       %Maybe we did not leave the emitters in Z:
       
       for k=1:length(disentangled_em)
           
           emitter        = disentangled_em(k);
           [~,state_flag] = qubit_in_product(Tab,n,emitter);
           
           if state_flag=='Y'
               
              Tab     = Phase_Gate(Tab,emitter,n);
              Tab     = Had_Gate(Tab,emitter,n);
              Circuit = store_gate_oper(emitter,'P',Circuit,Store_Gates);
              Circuit = store_gate_oper(emitter,'H',Circuit,Store_Gates);
              
           elseif state_flag=='X'
               
               Tab     = Had_Gate(Tab,emitter,n);
               Circuit = store_gate_oper(emitter,'H',Circuit,Store_Gates);
               
           end
           
       end
       
       return
       
   end
    
end


end


function [Tab,flag,Circuit,graphs,disentangled_em]=disentangle_two_emitters(Tab,np,ne,Circuit,graphs,Store_Graphs,Store_Gates,disentangled_em,BackSubs)

n             = np+ne;
cnt           = 0;
rest_emitters = np+1:n;

for l=1:length(disentangled_em)
        
    rest_emitters(rest_emitters==disentangled_em(l))=nan;
    
end

rest_emitters=rest_emitters(~isnan(rest_emitters));

for ll=1:length(rest_emitters) 
   
    [cond_emitter, ~] = qubit_in_product(Tab,n,rest_emitters(ll));
    
    if ~cond_emitter
       
        cnt=cnt+1;
        entangled_emitters(cnt)=rest_emitters(ll);
        
    else
        
        disentangled_em=[disentangled_em,rest_emitters(ll)];
        
    end
    
end

if cnt==0
    
    flag=true;

    return
    
else
    
    flag=false;
    
end

if ~BackSubs

    [optimal_row,~,~,~] = smallest_weight_Stab_em(Tab,np,ne,entangled_emitters);
    
else

    BackTab=Back_Subs_On_RREF_Tab(Tab,n,[]);
    [optimal_row,~,~,~] = smallest_weight_Stab_em(BackTab,np,ne,entangled_emitters);
    Tab=BackTab;  %This can bring further reduction in CNOTs.
                  %We could try again to find how to break into
                  %disconnected components, or perform parallel
                  %elimination.
end

SX_em         = Tab(optimal_row,entangled_emitters);
SZ_em         = Tab(optimal_row,entangled_emitters+n);

emm_in_Z0     = entangled_emitters(~SX_em &   SZ_em);
CNTZ          = length(emm_in_Z0);

if CNTZ==2
    
    %Now the emitters in the particular row are in Z. Apply CNOT on 2 of them.

    Tab     = CNOT_Gate(Tab,emm_in_Z0(1:2),n);
    Circuit = store_gate_oper(emm_in_Z0(1:2),'CNOT',Circuit,Store_Gates);

    Circuit.EmCNOTs = Circuit.EmCNOTs+1;

    if Store_Graphs
        
        graphs  = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',num2str(emm_in_Z0(1)),',',num2str(emm_in_Z0(2)),'} [DE]'),graphs);
        
    end
   
    return
    
end

emm_in_X = entangled_emitters( SX_em & ~ SZ_em);

for l1 = 1: length(emm_in_X)
    
   Tab     = Had_Gate(Tab,emm_in_X(l1),n);
   Circuit = store_gate_oper(emm_in_X(l1),'H',Circuit,Store_Gates); 
   
   CNTZ=CNTZ+1;
   
   if CNTZ==2
       
       break
   end
   
end

emm_in_Z = [emm_in_Z0,emm_in_X(1:l1)];

if CNTZ==2
    
    Tab     = CNOT_Gate(Tab,emm_in_Z(1:2),n);
    Circuit = store_gate_oper(emm_in_Z(1:2),'CNOT',Circuit,Store_Gates);


    Circuit.EmCNOTs = Circuit.EmCNOTs+1;
    
    if Store_Graphs
        graphs  = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',num2str(emm_in_Z(1)),',',num2str(emm_in_Z(2)),'} [DE]'),graphs);
    end
   
    return    
    
    
end


emm_in_Y = entangled_emitters( SX_em &   SZ_em);

for l2 = 1: length(emm_in_Y)
   
   Tab     = Phase_Gate(Tab,emm_in_Y(l2),n);
   Tab     = Had_Gate(Tab,emm_in_Y(l2),n);
   
   Circuit = store_gate_oper(emm_in_Y(l2),'P',Circuit,Store_Gates);
   Circuit = store_gate_oper(emm_in_Y(l2),'H',Circuit,Store_Gates);
   
   CNTZ=CNTZ+1;
   
   if CNTZ==2
       break
   end
   
   
end

emm_in_Z=[emm_in_Z0,emm_in_X(1:l1),emm_in_Y(1:l2)];

Tab     = CNOT_Gate(Tab,emm_in_Z(1:2),n);
Circuit = store_gate_oper(emm_in_Z(1:2),'CNOT',Circuit,Store_Gates);

Circuit.EmCNOTs = Circuit.EmCNOTs+1;

if Store_Graphs
    graphs  = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',num2str(emm_in_Z(1)),',',num2str(emm_in_Z(2)),'} [DE]'),graphs);
end


end

function [optimal_Stabrow,StabsXE,StabsZE,minW] = smallest_weight_Stab_em(Tab,np,ne,entangled_emitters)

n        = np+ne;
StabsXE  = Tab(:,entangled_emitters);
StabsZE  = Tab(:,entangled_emitters+n);

weight   = sum([StabsXE,StabsZE]'~=0);
emm_in_Y = sum(StabsXE' &   StabsZE');
weight   = weight-emm_in_Y;

locs     = weight>1;
weight   = weight(locs);
[minW,indx] = min(weight);

possible_rows   = 1:n;
possible_rows   = possible_rows(locs);
optimal_Stabrow = possible_rows(indx);

end