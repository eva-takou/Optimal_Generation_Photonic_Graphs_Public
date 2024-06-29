function [Gates,Qubits,updates_made]=Commutation_Rules...
                            (gatePrev,gateAfte,Gates,Qubits,qubit,locs_Q)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 29, 2024
%
%Function with a set of rules to commute Pauli Gates (X,Y,Z) closer to the 
%end of the circuit. If the next operation after a Pauli Gate is 
%measurement we do not perform an update.
%
%
%Input: gatePrev: The gate we want to commute
%       gateAfte: The next gate
%       Gates: A cell array of gates with char names e.g. 'X','CNOT' etc
%       Qubits: A cell array of the qubit numbers on which the gate acts
%       qubit: The index of the qubit on which we apply the commutation rules.
%       locs_Q: A 2x1 array of indices that point to the positions of the 2
%       operations that we want to commute (position in Gates and qubits list).
%Output: Gates: A cell array with the updates
%        Qubits: A cell array of qubits with the updates
%        updates_made: true or false if we changed something in the Gates
%        and Qubits list.

updates_made = true;

if strcmpi(gatePrev,'X')

    if strcmpi(gateAfte,'X') %Cancel out consecutive X gates

        Gates{locs_Q(1)}  = [];
        Qubits{locs_Q(1)} = [];
        Gates{locs_Q(2)}  = [];
        Qubits{locs_Q(2)} = [];

    elseif strcmpi(gateAfte,'Z') %XZ -> Y up to global phase

        Gates{locs_Q(1)}  = [];
        Qubits{locs_Q(1)} = [];        
        Gates{locs_Q(2)}  = 'Y';

    elseif strcmpi(gateAfte,'H') %Convert X before H to a Z gate after the H

        Gates{locs_Q(1)}  = [];
        Qubits{locs_Q(1)} = [];

        Gates  = [Gates(1:locs_Q(2)),'Z',Gates(locs_Q(2)+1:end)];
        Qubits = [Qubits(1:locs_Q(2)),qubit,Qubits(locs_Q(2)+1:end)];

    elseif strcmpi(gateAfte,'P') %P*X -> Y*P

        Gates{locs_Q(1)}  = [];
        Qubits{locs_Q(1)} = [];
        
        Gates  = [Gates(1:locs_Q(2)),'Y',Gates(locs_Q(2)+1:end)];
        Qubits = [Qubits(1:locs_Q(2)),qubit,Qubits(locs_Q(2)+1:end)];
    
    elseif strcmpi(gateAfte,'Pdag') %Pdag*X -> -Y*Pdag

        Gates{locs_Q(1)}  = [];
        Qubits{locs_Q(1)} = [];
        
        Gates  = [Gates(1:locs_Q(2)),'Y',Gates(locs_Q(2)+1:end)];
        Qubits = [Qubits(1:locs_Q(2)),qubit,Qubits(locs_Q(2)+1:end)];
        
        
    elseif strcmpi(gateAfte,'CNOT')    

        control = Qubits{locs_Q(2)}(1);
        target  = Qubits{locs_Q(2)}(2);

        Gates{locs_Q(1)}  = [];
        Qubits{locs_Q(1)} = [];

        if qubit==target %Commute the X gate

            Gates  = [Gates(1:locs_Q(2)),'X',Gates(locs_Q(2)+1:end)];
            Qubits = [Qubits(1:locs_Q(2)),qubit,Qubits(locs_Q(2)+1:end)];

        elseif qubit==control %Apply X gates on both qubits

            Gates  = [Gates(1:locs_Q(2)),'X','X',Gates(locs_Q(2)+1:end)];
            Qubits = [Qubits(1:locs_Q(2)),control,target,Qubits(locs_Q(2)+1:end)];

        end

    elseif strcmpi(gateAfte,'CZ')        
        
        control = Qubits{locs_Q(2)}(1);
        target  = Qubits{locs_Q(2)}(2);

        Gates{locs_Q(1)}  = [];
        Qubits{locs_Q(1)} = [];
        
        if qubit==control
           
            Gates  = [Gates(1:locs_Q(2)),'X','Z',Gates(locs_Q(2)+1:end)];
            Qubits = [Qubits(1:locs_Q(2)),control,target,Qubits(locs_Q(2)+1:end)];
            
        elseif qubit==target
            
            Gates  = [Gates(1:locs_Q(2)),'X','Z',Gates(locs_Q(2)+1:end)];
            Qubits = [Qubits(1:locs_Q(2)),target,control,Qubits(locs_Q(2)+1:end)];
            
        end

    elseif strcmpi(gateAfte,'Measure')

        updates_made=false;
        
        return
        
    elseif isempty(gateAfte) 
        
        updates_made=false;
        
        return

    end
    
elseif strcmpi(gatePrev,'Z')
    
    if strcmpi(gateAfte,'Z') %Cancel out consecutive Z gates
        
        Gates{locs_Q(1)}  = [];
        Gates{locs_Q(2)}  = [];
        Qubits{locs_Q(1)} = [];
        Qubits{locs_Q(2)} = [];
        
    elseif strcmpi(gateAfte,'X') %XZ -> Y up to a phase
        
        Gates{locs_Q(1)}  = [];
        Qubits{locs_Q(1)} = [];
        Gates{locs_Q(2)}  = 'Y';
        
    elseif strcmpi(gateAfte,'H') %Pass as an X gate
        
        Gates{locs_Q(1)}  = [];
        Qubits{locs_Q(1)} = [];
        
        Gates  =[Gates(1:locs_Q(2)),'X',Gates(locs_Q(2)+1:end)];
        Qubits =[Qubits(1:locs_Q(2)),qubit,Qubits(locs_Q(2)+1:end)];
        
    elseif strcmpi(gateAfte,'P') || strcmpi(gateAfte,'Pdag') %Commute after P
        
        Gates{locs_Q(1)}  = [];
        Qubits{locs_Q(1)} = [];
        
        Gates  = [Gates(1:locs_Q(2)),'Z',Gates(locs_Q(2)+1:end)];
        Qubits = [Qubits(1:locs_Q(2)),qubit,Qubits(locs_Q(2)+1:end)];
        
    elseif strcmpi(gateAfte,'CZ') %Commute after CZ
        
        Gates{locs_Q(1)}  = [];
        Qubits{locs_Q(1)} = [];
        
        Gates  = [Gates(1:locs_Q(2)),'Z',Gates(locs_Q(2)+1:end)];
        Qubits = [Qubits(1:locs_Q(2)),qubit,Qubits(locs_Q(2)+1:end)];
        
    elseif strcmpi(gateAfte,'CNOT')
        
        Gates{locs_Q(1)}  = [];
        Qubits{locs_Q(1)} = [];
        
        control = Qubits{locs_Q(2)}(1);
        target  = Qubits{locs_Q(2)}(1);
        
        if qubit==target
        
            Gates  = [Gates(1:locs_Q(2)),'Z','Z',Gates(locs_Q(2)+1:end)];
            Qubits = [Qubits(1:locs_Q(2)),control,target,Qubits(locs_Q(2)+1:end)];
            
        elseif qubit==control
            
            Gates  = [Gates(1:locs_Q(2)),'Z',Gates(locs_Q(2)+1:end)];
            Qubits = [Qubits(1:locs_Q(2)),control,Qubits(locs_Q(2)+1:end)];
             
        end
        
    elseif strcmpi(gateAfte,'Measure')
        
        updates_made=false;
        
        return
        
    elseif isempty(gateAfte)
        
        updates_made=false;
        
        return
        
        
    end
   
elseif strcmpi(gatePrev,'Y')
    
    if strcmpi(gateAfte,'Y') %Cancel out.
        
        Gates{locs_Q(1)}  = [];
        Gates{locs_Q(2)}  = [];
        Qubits{locs_Q(1)} = [];
        Qubits{locs_Q(2)} = [];
        
    elseif strcmpi(gateAfte,'X') %XY -> Z up to phase
        
        Gates{locs_Q(1)}  = [];
        Qubits{locs_Q(1)} = [];
        Gates{locs_Q(2)}  = 'Z';
        
    elseif strcmpi(gateAfte,'Z') %ZY -> X up to phase
        
        Gates{locs_Q(1)}  = [];
        Qubits{locs_Q(1)} = [];
        Gates{locs_Q(2)}  = 'X';
        
    elseif strcmpi(gateAfte,'H') %Same up to (-1) sign.
        
        Gates{locs_Q(1)}  = [];
        Qubits{locs_Q(1)} = [];

        Gates  = [Gates(1:locs_Q(2)),'Y',Gates(locs_Q(2)+1:end)];
        Qubits = [Qubits(1:locs_Q(2)),qubit,Qubits(locs_Q(2)+1:end)];
        
        
    elseif strcmpi(gateAfte,'P') || strcmpi(gateAfte,'Pdag') %Y then P is P then X (up to global phase)
        
        Gates{locs_Q(1)}  = [];
        Qubits{locs_Q(1)} = [];

        Gates  = [Gates(1:locs_Q(2)),'X',Gates(locs_Q(2)+1:end)];
        Qubits = [Qubits(1:locs_Q(2)),qubit,Qubits(locs_Q(2)+1:end)];
        
    elseif strcmpi(gateAfte,'CNOT')
        
        control = Qubits{locs_Q(2)}(1);
        target  = Qubits{locs_Q(2)}(2);        

        Gates{locs_Q(1)}  = [];
        Qubits{locs_Q(1)} = [];        
        
        if qubit==control
            
            Gates  = [Gates(1:locs_Q(2)),'Y','X',Gates(locs_Q(2)+1:end)];
            Qubits = [Qubits(1:locs_Q(2)),control,target,Qubits(locs_Q(2)+1:end)];
            
        elseif qubit==target            
            
            Gates  = [Gates(1:locs_Q(2)),'Z','Y',Gates(locs_Q(2)+1:end)];
            Qubits = [Qubits(1:locs_Q(2)),control,target,Qubits(locs_Q(2)+1:end)];
            
        end
        
    elseif strcmpi(gateAfte,'CZ')
        
        control = Qubits{locs_Q(2)}(1);
        target  = Qubits{locs_Q(2)}(2);
        
        Gates{locs_Q(1)}  = [];
        Qubits{locs_Q(1)} = [];        
        
        if qubit==control 
            
            Gates  = [Gates(1:locs_Q(2)),'Y','Z',Gates(locs_Q(2)+1:end)];
            Qubits = [Qubits(1:locs_Q(2)),control,target,Qubits(locs_Q(2)+1:end)];
            
        elseif qubit==target
            
            Gates  = [Gates(1:locs_Q(2)),'Z','Y',Gates(locs_Q(2)+1:end)];
            Qubits = [Qubits(1:locs_Q(2)),control,target,Qubits(locs_Q(2)+1:end)];

        end
        
    elseif strcmpi(gateAfte,'Measure')
        
        updates_made=false;
        return
        
    elseif isempty(gateAfte)
        
        updates_made=false;
        return 
        
    end
    
else %Neither X or Z or Y
    
    updates_made=false;
    return
    
end

end