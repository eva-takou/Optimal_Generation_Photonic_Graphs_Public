function m=double_occurrence_RGS(num_core_qubits)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 25, 2024
%--------------------------------------------------------------------------
%
%Script to produce the alternance word of an RGS state.a
%
%Input: num_core_qubits: # of core nodes
%Output: m: The alternance word


core_qubits = 1:num_core_qubits;
m           = [core_qubits,core_qubits];
leaves      = num_core_qubits+1:2*num_core_qubits; %1 leaf per core_qubit


for jj=1:length(leaves)
    
    index = find(m==core_qubits(jj),1,'last'); 
    newm  = zeros(1,length(m)+2);
    
    newm(1:index-1)   = m(1:index-1); 
    newm(index)       = leaves(jj); %put the 1st occurrence of the leaf right before last occurence of core qubit
    newm(index+1)     = m(index);
    newm(index+2)     = leaves(jj); %put the last occurrence of the leaf right after last occurence of core qubit
    newm(index+3:end) = m(index+1:end);
    
    m = newm;
    
end

end