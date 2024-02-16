function [Tab,Circuit,graphs]=photon_absorption_W_CNOT(Tab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates)
%Function to perform photon absorption in the case where we need emitter
%gates first. There can be at most 2 photonic rows that start with
%non-trivial Pauli from the photon to be absorbed. We pick the photonic row 
%with smallest weight on emitter Paulis, and pick the 1st emitter with 
%non-trivial Pauli to absorb the photon. 
%Inputs: Tab: Tableau
%        np: # of photons
%        ne: # of emitters
%        photon: # index of photon to be absorbed
%        Circuit: the circuit we have so far
%        graphs: the graph evolution as we evolve the circuit.
%        Store_Graphs: true or false to store the graph evolution.
%        Store_Gates: true or false to store the gates.
%Output: Tab: The updated tableau
%        Circuit: The updated circuit
%        graphs: The updated graphs


n=np+ne;
disp(['Emitters are entangled. Need gates before photon absorption of photon #',num2str(photon)])

%Get stabs whose left index starts from a Pauli on the photon to be absorbed
[potential_rows,photon_flag_Gate] = detect_Stabs_start_from_photon(Tab,photon,n);

[row_id,indx] = detect_Stab_rows_of_minimal_weight(Tab,potential_rows,np,n);
[emitters_in_X,emitters_in_Y,emitters_in_Z]=emitters_Pauli_in_row(Tab,row_id,np,ne);

%-------- Bring all emitters in Z for the particular row: -----------------
[Tab,Circuit]=put_emitters_in_Z(n,Tab,Circuit,emitters_in_X,emitters_in_Y,Store_Gates);


possible_emitters = [emitters_in_X,emitters_in_Y,emitters_in_Z];

%----- Choose the 1st emitter (do not inspect emitter choice) -------------

emitter        = possible_emitters(1);
other_emitters = possible_emitters(2:end);

[Tab,Circuit,graphs]=free_emitter_for_PA(n,Tab,Circuit,graphs,Store_Graphs,emitter,other_emitters,Store_Gates);

emitter_flag_Gate='Z';

[Tab,Circuit,graphs]=PA_subroutine(n,Tab,Circuit,graphs,photon,emitter,emitter_flag_Gate,photon_flag_Gate{indx},Store_Graphs,Store_Gates);

end


function [Stab_row_indx,indx] = detect_Stab_rows_of_minimal_weight(Tab,potential_rows,np,n)

ne               = n-np;
Lp               = length(potential_rows);
weight           = zeros(1,Lp);
emitters_per_row = cell(1,Lp);

for ll=1:Lp

    row = potential_rows(ll);
    
    [emitters_in_X,emitters_in_Y,emitters_in_Z] = emitters_Pauli_in_row(Tab,row,np,ne);
    weight(ll)           = length([emitters_in_X,emitters_in_Y,emitters_in_Z]);
    emitters_per_row{ll} = [emitters_in_X,emitters_in_Y,emitters_in_Z];
    
end

if min(weight)==0
   error('Error in photonic absorption. Found stab with support on target photon, but no support on any emitter.') 
end

[~,indx]      = min(weight);
Stab_row_indx = potential_rows(indx);

end
