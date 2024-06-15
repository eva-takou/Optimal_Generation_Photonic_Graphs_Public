function [Tab,Circuit,graphs]=PA_subroutine(n,Tab,Circuit,graphs,photon,emitter,emitter_flag_Gate,photon_flag_Gate,Store_Graphs,Store_Gates)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 15, 2024
%--------------------------------------------------------------------------
%
%Subroutine to do photon absorption.
%
%Input:  n: total # of qubits
%        Tab: Tableau
%        Circuit: The circuit so far
%        graphs: The graphs so far
%        photon: The photon index \in [1,np]
%        emitter: The emitter index in [np+1,n]
%        emitter_flag_Gate: 'X','Y' or 'Z'
%        photon_flag_Gate: 'X', 'Y' or 'Z'
%        Store_Graphs: true or false
%        Store_Gates: true or false
%Output: Tab: the updated tableau
%        Circuit: the updated circuit
%        graphs: the updated graphs

switch emitter_flag_Gate %Bring the emitter to Z

  case 'X'

        Tab     = Had_Gate(Tab,emitter,n);
        Circuit = store_gate_oper(emitter,'H',Circuit,Store_Gates);   

  case 'Y'

        Tab     = Phase_Gate(Tab,emitter,n);
        Tab     = Had_Gate(Tab,emitter,n);
        Circuit = store_gate_oper(emitter,'P',Circuit,Store_Gates);   
        Circuit = store_gate_oper(emitter,'H',Circuit,Store_Gates);   
   
end

switch photon_flag_Gate %Bring the photon to Z

  case 'X'

      Tab     = Had_Gate(Tab,photon,n);
      Circuit = store_gate_oper(photon,'H',Circuit,Store_Gates);  

  case 'Y'

      Tab     = Phase_Gate(Tab,photon,n);
      Tab     = Had_Gate(Tab,photon,n);
      Circuit = store_gate_oper(photon,'P',Circuit,Store_Gates);   
      Circuit = store_gate_oper(photon,'H',Circuit,Store_Gates);   

end

Tab     = CNOT_Gate(Tab,[emitter,photon],n); %photon and emitter in Z
Circuit = store_gate_oper([emitter,photon],'CNOT',Circuit,Store_Gates); 

if Store_Graphs
    
    graphs  = store_graph_transform(Get_Adjacency(Tab),...
        strcat('After CNOT_{',num2str(emitter),',',num2str(photon),'} [PA]'),graphs);
end

end
