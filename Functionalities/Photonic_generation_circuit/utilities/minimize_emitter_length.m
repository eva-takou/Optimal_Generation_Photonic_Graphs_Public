function [emitter_qubit,other_emitters,Tab,Circuit,min_Stabrow]=minimize_emitter_length(Tab,Circuit,n,np,ne,not_absorbed_photons,Store_Gates)
%Function to choose a stabilizer row which has solely support on emitters
%and pick the row with minimal weight on the emitter qubits.
%This is used for time reversed measurement.
%Input: Tab: Tableau
%       Circuit: The circuit that we have so far
%       n: total # of qubits
%       np: # of photons
%       ne: # of emitters
%Output: emitter_qubit: qubit to be used
%        other_emitters: the remaining emitters in the particular
%        stabilizer row [all have been put in Z]
%        Tab: The updated tableau after putting the emitters in Z
%        Circuit: the updated circuit
%        n: total # of qubits
%        np: # of photons
%        ne: # of emitters

row_indx_Stabs = Stabs_with_support_on_emitters(Tab,np,ne,not_absorbed_photons);
LS             = length(row_indx_Stabs);

emm_in_X       = cell(1,LS);
emm_in_Y       = cell(1,LS);
emm_in_Z       = cell(1,LS);
emitter_length = zeros(1,LS);

for ll=1:LS

   StabRow     = Tab(row_indx_Stabs(ll),:);
   SX_emitters = StabRow(np+1:n);
   SZ_emitters = StabRow((np+1)+n:2*n);

   Xpos = SX_emitters>0;
   Zpos = SZ_emitters>0;
   
   emm_in_X{ll}       = ( Xpos  & ~Zpos);
   emm_in_Y{ll}       = ( Xpos  &  Zpos);
   emm_in_Z{ll}       = (~Xpos  &  Zpos);
    
   emitter_length(ll) = sum([emm_in_X{ll},emm_in_Y{ll},emm_in_Z{ll}]);
   
end

[~,lmin]    = min(emitter_length); %Choose a stab that has smallest stabilizer weight - will need smaller number of CNOTs to disentangle 1 emitter.
min_Stabrow = row_indx_Stabs(lmin);

SX_emitters = Tab(row_indx_Stabs(lmin),np+1:n);
SZ_emitters = Tab(row_indx_Stabs(lmin),np+1+n:2*n);
Xpos        = SX_emitters>0;
Zpos        = SZ_emitters>0;

emm_in_X    = find( Xpos & ~Zpos )+np;
emm_in_Y    = find( Xpos &  Zpos )+np;

for jj=1:length(emm_in_X)

  Tab     = Had_Gate(Tab,emm_in_X(jj),n);
  Circuit = store_gate_oper(emm_in_X(jj),'H',Circuit,Store_Gates); 

end

for jj=1:length(emm_in_Y)

   Tab = Phase_Gate(Tab,emm_in_Y(jj),n); 
   Tab = Had_Gate(Tab,emm_in_Y(jj),n); 
   
   Circuit = store_gate_oper(emm_in_Y(jj),'P',Circuit,Store_Gates); 
   Circuit = store_gate_oper(emm_in_Y(jj),'H',Circuit,Store_Gates); 
   
end

%Now all emitters in this row of stabs are in Z
SX_emitters = Tab(row_indx_Stabs(lmin),(np+1):n);
SZ_emitters = Tab(row_indx_Stabs(lmin),(np+1)+n:2*n);
emm_in_Z    = find(SZ_emitters & ~SX_emitters);



%Pick the 1st one:
emitter_qubit  = emm_in_Z(1); %Will be used next for TRM
other_emitters = emm_in_Z(2:end);

emitter_qubit  = emitter_qubit+np;
other_emitters = other_emitters+np;


end
