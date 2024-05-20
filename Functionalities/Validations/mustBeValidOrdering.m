function mustBeValidOrdering(ordering,n)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 20, 2024
%
%Throw an error if the node ordering is not valid. The node ordering
%corresponds to an ordering of the labels of the graph.
%Input: ordering: The ordering of the nodes (vector with n elements)
%       n: # of qubits

if length(unique(ordering))~=length(ordering)
    
     ME = MException('mustBeValidOrdering:inputError','Detected duplicate labels for the qubits.');
     throw(ME)
    
end

if length(ordering)~=n
    
    ME = MException('mustBeValidOrdering:inputError','The size of the ordering elements does not match the number of qubits.');
    throw(ME)
    
end

end