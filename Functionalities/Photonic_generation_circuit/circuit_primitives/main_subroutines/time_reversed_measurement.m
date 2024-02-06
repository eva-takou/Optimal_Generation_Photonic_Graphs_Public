function [Tab,Circuit,graphs]=time_reversed_measurement(Tab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates)
%Function to perform time reversed measurement of the emitter, when photon
%absorption is not possible.
%Inputs: Tab: Tableau
%        np: # of photons
%        ne: # of emitters
%        photon: photon index of photon to be absorbed.
%        Circuit: the circuit that we have so far
%        graphs: the graphs for each step of the generation
%        Store_Graphs: true or false to store the updates on the graph
%        level.
%Output: Tab: The updated tableau
%        Circuit: The updated circuit
%        graphs: The updated graphs
%
%1) Find emitter in |0> state (with stab that has support only on the emitter sites).
%2) Bring it into |+> state.
%3) Do CNOT_{ij} between the emitter and the current photon.
%
%The TRM measurement, will connect an emitter with the neighborhood of the
%photon to be absorbed. 

n = np+ne;

for emitter_qubit=np+1:n
    
    [discovered, state_flag] = qubit_in_product(Tab,n,emitter_qubit);
    
    if discovered %true, and can be just any emitter qubit (no freedom in TRM)
        
       switch state_flag
           
           case 'Y'
               
               Tab     = Phase_Gate(Tab,emitter_qubit,n);  %Convert to eigenstate of X (up to phase)
               Circuit = store_gate_oper(emitter_qubit,'P',Circuit,Store_Gates); 
                                        
           case 'Z'
               
               Tab     = Had_Gate(Tab,emitter_qubit,n); %Convert to eigenstate of X
               Circuit = store_gate_oper(emitter_qubit,'H',Circuit,Store_Gates); 
       end
       
       Tab     = CNOT_Gate(Tab,[emitter_qubit,photon],n); %This TRM will connect the emitter with N(photon).
       Circuit = store_gate_oper([emitter_qubit,photon],'Measure',Circuit,Store_Gates); 
       
            
       if Store_Graphs
            graphs  = store_graph_transform(Get_Adjacency(Tab),...
                strcat('After CNOT_{',num2str(emitter_qubit),',',num2str(photon),'} [TRM]'),graphs);
       end
       
       
       disp(['Applied TRM on emitter:',num2str(emitter_qubit)])
       
       return
       
    end
    
end

%If function didn't return above then we need CNOT emitter gates.

disp('Need emitter gates before TRM.') 

not_absorbed_photons=1:photon;
[emitter_qubit,other_emitters,Tab,Circuit]=minimize_emitter_length(Tab,Circuit,n,np,ne,not_absorbed_photons,Store_Gates);


for jj=1:length(other_emitters) %disentangle emitters
    
   control = other_emitters(jj);
   Tab     = CNOT_Gate(Tab,[control,emitter_qubit],n);
   Circuit = store_gate_oper([control,emitter_qubit],'CNOT',Circuit,Store_Gates); 
   
   if Store_Graphs
        graphs  = store_graph_transform(Get_Adjacency(Tab),...
            strcat('After CNOT_{',num2str(control),',',num2str(emitter_qubit),'} [DE]'),graphs);
   end
end

Circuit.EmCNOTs = Circuit.EmCNOTs+length(other_emitters);

%Put the emitter in |+>
Tab           = Had_Gate(Tab,emitter_qubit,n);
%Now do the TRM
Tab           = CNOT_Gate(Tab,[emitter_qubit,photon],n);

Circuit = store_gate_oper(emitter_qubit,'H',Circuit,Store_Gates); 
Circuit = store_gate_oper([emitter_qubit,photon],'Measure',Circuit,Store_Gates); 

if Store_Graphs
    graphs  = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',num2str(emitter_qubit),',',num2str(photon),'} [TRM]'),graphs);
end

disp(['Applied TRM on emitter:',num2str(emitter_qubit)])
end


