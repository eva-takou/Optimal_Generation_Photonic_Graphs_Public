function [Circuit]=pass_X_gates(Circuit,np)
%Script to pass X gates after the emissions of photons.

Gates  = flip(Circuit.Gate.name);
qubits = flip(Circuit.Gate.qubit);
   


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
        continue
    end
    
    for k=Xpos+1:length(Gates)
        
        if any(qubits{k}==photon) && strcmpi(Gates{k},'CNOT')
        
            CNOT_pos=k;
            Q = qubits{k};
            break
            
        end
        
    end
    
    Gates        =[Gates(1:CNOT_pos),{'X'},Gates(CNOT_pos+1:end)];
    qubits       =[qubits(1:CNOT_pos),{photon},qubits(CNOT_pos+1:end)];
    Gates{Xpos}  =[];
    qubits{Xpos} =[];
    
    
end
[Gates,qubits]=remove_empty_slots(Gates,qubits);
Circuit.Gate.name=flip(Gates);
Circuit.Gate.qubit=flip(qubits);




end