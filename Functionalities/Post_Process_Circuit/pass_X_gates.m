function [Circuit]=pass_X_gates(Circuit,np,CircuitOrder)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 28, 2024
%
%Script to pass initial X gates on photons after their emission. We can do
%that because [CX,IX]=0. The initial X gates arise when we correct phases
%on stabilizers in the end of the backwards generation.
%
%Input: Circuit: The Circuit as a struct Circuit.Gate with fields qubit and
%                name
%       np: # of photons involved in the circuit
%
%Output: The updated circuit.

if strcmpi(CircuitOrder,'backward') %Put to forward order
    
    Gates  = flip(Circuit.Gate.name);
    qubits = flip(Circuit.Gate.qubit);
    
end

for photon=1:np
    
    Xpos=[];
    
    for k=1:length(Gates)
        
        %Check first gate that involves this photon:
        if any(qubits{k}==photon) && strcmpi(Gates{k},'X')
           
           %Mark this position:
           Xpos = k;
           
           break
            
        end
        
        
    end
    
    if isempty(Xpos)
        continue %This photon is not acted by initial X gate
    end
    
    for k=Xpos+1:length(Gates)
        
        if any(qubits{k}==photon) && strcmpi(Gates{k},'CNOT')
        
            CNOT_pos = k;
            break
            
        end
        
    end
    
    Gates        =[Gates(1:CNOT_pos),{'X'},Gates(CNOT_pos+1:end)];
    qubits       =[qubits(1:CNOT_pos),{photon},qubits(CNOT_pos+1:end)];
    Gates{Xpos}  =[]; %Make the initial 'X' in the list empty
    qubits{Xpos} =[]; %Make the qubit index also empty
    
end

[Gates,qubits]     = remove_empty_slots(Gates,qubits);

%Return backwards circuit
Circuit.Gate.name  = flip(Gates);
Circuit.Gate.qubit = flip(qubits);

end