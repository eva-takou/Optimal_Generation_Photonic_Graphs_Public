function [Gate_Sequence2]=Simplify_Circuit(Circuit,np,ne,circuitOrder,ConvertToCZ,...
                                           pass_X_photons,pass_emitter_Paulis,Init_State_Option,...
                                           monitor_update,pause_time,fignum)

%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 4, 2024
%
%Function to simplify/make edits to a quantum circuit.
%
%Input: Circuit: A struct with fields .Gate.name and .Gate.qubit
%       np: # of photons involved in the Circuit
%       ne: # of emitters involved in the Circuit
%       circuitOrder: If the circuit is passed in reverse order use 'backward'
%       ConvertToCz: true or false to convert CNOTs to CZs
%       pass_X: true or false to pass X gates towards the end of the
%       circuit
%       Init_State_Option: '0' or '+', it is for drawing purposes on how to
%       display the qubits. Default is '0'. If '+' is selected, then all
%       qubits can be put displayed in the circuit in '+' as long as the
%       first gate that acts on them is the Hadamard,
%       monitor_update: true or false to update changes in same figure
%       dynamically
%       pause_time: time in (s) before next update appears in the figure
%       fignum: figure index to display the results of simplification/new
%       circuit
%
%Output: The updated gate sequence after edits/simplifications. It is
%        returned as 'backward' order if input was 'backward' order, or 
%        'forward' order if input was 'forward' order.

layer_shift = 1;      %For spacing of boxes in the circuit visualization
n           = np+ne;
Gates       = Circuit.Gate.name;
Qubits      = Circuit.Gate.qubit;
%--------------------------------------------------------------------------
if monitor_update %Show input circuit
    
    figure(fignum)
    clf('reset') 
    draw_circuit(np,ne,Circuit,circuitOrder,layer_shift,'0')
    pause(pause_time)
    
end

if strcmpi(circuitOrder,'backward') %Put circuit in forward order & do P->Pdag
    
    Circuit = put_circuit_forward_order(Circuit);
    Gates   = Circuit.Gate.name;
    Qubits  = Circuit.Gate.qubit;
    
end

%=========== 1st Step: Pass X gates on photons by 2 layers  ===============

if pass_X_photons
   
    Gate_Sequence2.Gate.name  = Gates; %Forward
    Gate_Sequence2.Gate.qubit = Qubits;
    CircuitOrder              = 'forward';
    
    %Pass any initial X gates on photons after the CNOTs (emissions).
    [Gate_Sequence2] = pass_X_gates(Gate_Sequence2,np,CircuitOrder);
    
    Gates  = Gate_Sequence2.Gate.name;  %Still forward order
    Qubits = Gate_Sequence2.Gate.qubit;
    
    if monitor_update
    
        plot_update(np,ne,pause_time,Gates,Qubits,Init_State_Option,CircuitOrder,fignum)        
        
    end
       
    %Find where the X gate is now and pass it one step further.
    
    for jj=1:np

        locs_Q=[];
        
        for kk=1:length(Gates)

            if any(Qubits{kk}==jj) && strcmpi(Gates{kk},'X')
                
               locs_Q=[locs_Q,kk]; 
               break
               
            end
                
        end        
        
        if isempty(locs_Q)
           
            continue
            
        end
        
        for kk=locs_Q(1)+1:length(Gates)
           
            if any(Qubits{kk}==jj) 
               
                locs_Q=[locs_Q,kk];
                break
            end
            
        end
        
        if length(locs_Q)<2 
            continue
        end
        
        [Gates,Qubits,~] = Commutation_Rules(Gates{locs_Q(1)},Gates{locs_Q(2)},Gates,Qubits,jj,locs_Q);
        [Gates,Qubits]   = remove_empty_slots(Gates,Qubits);
        
        if monitor_update
           
            plot_update(np,ne,pause_time,Gates,Qubits,Init_State_Option,CircuitOrder,fignum)
            
        end
        
        
    end
    
end

%=========== 2nd Step: Convert CNOTs to CZs ===============================

%return

CircuitOrder = 'forward';

if ConvertToCZ

    conversion_done = false;
    
    while ~conversion_done
        
        cnt=0;
        
        for kk = 1:length(Gates)
           
            if strcmpi(Gates{kk},'CNOT')
                
                cnt             = cnt+1;
                conversion_done = false;
                break %kk is kept as CNOT position
            
            end
            
        end

        if cnt==0 %Conversion complete.
            
            conversion_done = true;
            continue %Exit in next iter
        end        
        
        %Apply the rule:
        
        [Gates,Qubits] = CNOT_to_CZ(Gates,Qubits,kk);
        
        if monitor_update
           
            plot_update(np,ne,pause_time,Gates,Qubits,Init_State_Option,CircuitOrder,fignum)
            
        end
        
    end
    
end

%=========== 3rd Step: Cancel out redundant gates =========================

[Gates,Qubits] = cancel_out_gates(Gates,Qubits,n);

if monitor_update

    plot_update(np,ne,pause_time,Gates,Qubits,Init_State_Option,CircuitOrder,fignum)

end
 
%== 4th Step: Pass 'X'/'Z' gates acting on emitters towards the end =======

if pass_emitter_Paulis
    
    %Repeat till no more Pauli is in main part of circuit (all are pushed
    %right before Z-basis measurement)
    
    tic;
    while true
            
        [Gates,Qubits]=move_emitter_Paulis_for_each_rail(np,ne,pause_time,...
                       Gates,Qubits,Init_State_Option,CircuitOrder,...
                       fignum,monitor_update);    
        
        [Gates,Qubits]=cancel_out_gates(Gates,Qubits,n);
        [Gates,Qubits]=remove_empty_slots(Gates,Qubits);
        
        flag_continue=false;
        
        for k=1:length(Gates)
           
            if strcmpi(Gates{k},'Measure')
                
                emitter  = Qubits{k}(1);

                for l=k-1:-1:1

                    if strcmpi(Gates{l},'H') && Qubits{l}==emitter

                        indx_H = l;
                        break
                    end

                end                
                
                for l=indx_H-1:-1:1

                    if all(Qubits{l}==emitter)

                        if strcmpi(Gates{l},'X') || strcmpi(Gates{l},'Y') || strcmpi(Gates{l},'Z')

                            flag_continue=true;
                            break

                        end

                    end

                end                
                
            end
            
            
            if flag_continue
                break
            end
            
            
        end
        
        if ~flag_continue
            break
        end
            
    end

    %Bring Pauli before H gates of TRM:
    
    for k=1:length(Gates)
       
        if strcmpi(Gates{k},'Measure')
           
            indx_TRM = k;
            emitter  = Qubits{k}(1);
            
            for l=k-1:-1:1

                if strcmpi(Gates{l},'H') && Qubits{l}==emitter

                    indx_H = l;
                    break
                end

            end            
            
            indx_X = []; indx_Y = []; indx_Z = [];
            
            for l=indx_H:indx_TRM

                if strcmpi(Gates{l},'X') && Qubits{l}==emitter

                    indx_X  = l;
                    break

                elseif strcmpi(Gates{l},'Y') && Qubits{l}==emitter

                    indx_Y  = l;
                    break

                elseif strcmpi(Gates{l},'Z') && Qubits{l}==emitter

                    indx_Z  = l;
                    break

                end

            end
            
            indx_Pauli = [indx_X,indx_Y,indx_Z];

            if isempty(indx_Pauli) 

                continue

            else %Restore Pauli before H gate

                if ~isempty(indx_X) && indx_X<indx_TRM && indx_X>indx_H

                    Gates{indx_X}  = [];
                    Qubits{indx_X} = [];

                    Gates  = [Gates(1:indx_H-1),'Z',Gates(indx_H:end)];
                    Qubits = [Qubits(1:indx_H-1),emitter,Qubits(indx_H:end)];

                elseif ~isempty(indx_Y) && indx_Y<indx_TRM && indx_Y>indx_H

                    Gates{indx_Y}  = [];
                    Qubits{indx_Y} = [];

                    Gates  = [Gates(1:indx_H-1),'Y',Gates(indx_H:end)];
                    Qubits = [Qubits(1:indx_H-1),emitter,Qubits(indx_H:end)];


                elseif ~isempty(indx_Z) && indx_Z<indx_TRM && indx_Z>indx_H

                    Gates{indx_Z}  = [];
                    Qubits{indx_Z} = [];

                    Gates  = [Gates(1:indx_H-1),'X',Gates(indx_H:end)];
                    Qubits = [Qubits(1:indx_H-1),emitter,Qubits(indx_H:end)];

                end


                [Gates,Qubits] = remove_empty_slots(Gates,Qubits);

                if monitor_update

                    plot_update(np,ne,pause_time,Gates,Qubits,Init_State_Option,CircuitOrder,fignum)

                end            



            end
            
        end
        
    end
    
end

if strcmpi(circuitOrder,'backward') %Return again backward
    
    Gate_Sequence2.Gate.name  = Gates;
    Gate_Sequence2.Gate.qubit = Qubits;
    Gate_Sequence2            = put_circuit_backward_order(Gate_Sequence2);
    
else
    
    Gate_Sequence2.Gate.name  = Gates;
    Gate_Sequence2.Gate.qubit = Qubits;
    
end

end

function plot_update(np,ne,pause_time,Gates,Qubits,Init_State_Option,circuit_order,fignum)
%The order of the Circuit needs to be 'forward'.

layer_shift = 1;

[Gates,Qubits]           = remove_empty_slots(Gates,Qubits);

Gate_Sequence.Gate.name  = Gates;
Gate_Sequence.Gate.qubit = Qubits;

figure(fignum)
clf('reset') 
draw_circuit(np,ne,Gate_Sequence,circuit_order,layer_shift,Init_State_Option)
pause(pause_time)  

end


function [Gates,Qubits]=move_emitter_Paulis_for_each_rail(np,ne,pause_time,...
                                                         Gates,Qubits,...
                                      Init_State_Option,CircuitOrder,fignum,...
                                      monitor_update)
n = np+ne;
for jj = np+1:n %Loop over emitters
                %Push Paulis right before the emitter measurements

    exitflag = false;

    while ~exitflag

        locs_Q = [];

        for kk = 1:length(Gates)

            if length(Qubits{kk})==1 && Qubits{kk}==jj %Single-qubit gate

                %Is it a Pauli?
                if strcmpi(Gates{kk},'X') || strcmpi(Gates{kk},'Y') ...
                                          || strcmpi(Gates{kk},'Z')

                   locs_Q = [locs_Q,kk];                   
                   break                   
                end

            end

        end

        if isempty(locs_Q) %No Pauli detected

            exitflag = true; %exit in next iteration
            continue

        end

        %Find next gate that involves the jj-th qubit

        for l=locs_Q(1)+1:length(Gates)

            if any(Qubits{l}==jj)

                locs_Q = [locs_Q,l];
                break

            end

        end

        if length(locs_Q)==1

            exitflag = true; %exit in next iteration
            continue

        end

        [Gates,Qubits,updates_made] = Commutation_Rules(Gates{locs_Q(1)},Gates{locs_Q(2)},Gates,Qubits,jj,locs_Q); %Commute Pauli by 1 step
        [Gates,Qubits]              = remove_empty_slots(Gates,Qubits);


        if monitor_update

            plot_update(np,ne,pause_time,Gates,Qubits,Init_State_Option,CircuitOrder,fignum)

        end             

        [Gates,Qubits]              = cancel_out_gates(Gates,Qubits,n);

        if ~updates_made

            exitflag = true; %exit in next iteration
            continue

        end

        if monitor_update

            plot_update(np,ne,pause_time,Gates,Qubits,Init_State_Option,CircuitOrder,fignum)

        end             

    end

end

end
