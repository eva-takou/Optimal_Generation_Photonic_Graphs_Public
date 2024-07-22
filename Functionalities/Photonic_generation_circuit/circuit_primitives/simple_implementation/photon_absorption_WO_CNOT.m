function [Tab,Circuit,graphs,discovered_emitter,emitter]=...
    photon_absorption_WO_CNOT(Tab,np,ne,photon,Circuit,graphs,...
                              Store_Graphs,Store_Gates,return_cond)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 15, 2024
%--------------------------------------------------------------------------
%
%
%Function to try to perform 'free' photon absorption (PA),i.e., w/o needing
%emitter-emitter CNOTs. If there is no available emitter, exit with the 
%same tableau, circuit and graphs, and output that an emitter was not 
%discovered.
%
%Inputs: Tab: Tableau
%        np: # of photons
%        ne: # of emitters
%        photon: # index of photon to be absorbed
%        Circuit: the circuit we have so far
%        graphs: the graph evolution as we evolve the circuit.
%        Store_Graphs: true or false to store graph evolution.
%        Store_Gates: true or false to store the gates.
%        return_cond: true for early exit, false for trying again free PA 
%                     after Back-substitution
%Output: Tab: The updated tableau
%        Circuit: The updated circuit
%        graphs: The updated graphs
%        discovered emitter: true or false if the free photon absorption
%                            happened.
%        emitter: if the above is true, it gives the index from np+1:n of 
%                 the emitter, if the above is false then emitter is empty.

n                  = np+ne;
discovered_emitter = false;
emitter            = [];

%Get stabs whose left index starts from a Pauli on the photon to be absorbed
[potential_rows,photon_flag_Gate,Tab] = detect_Stabs_start_from_photon(Tab,photon,n);

for jj=1:length(potential_rows) %Check for emitter not entangled with others to absorb the photon:
    
    [emitter,emitter_flag_Gate] = check_for_single_emitter(Tab,n,np,potential_rows(jj)); %Excludes emitters in product state from the row
    
    if ~isempty(emitter)
        
        discovered_emitter = true;
        photon_flag_Gate   = photon_flag_Gate{jj};
        
        disp(['Emitter #',int2str(emitter), ' can absorb photon #',int2str(photon),' w/o emitter gates.']) 

        [Tab,Circuit,graphs]=PA_subroutine(n,Tab,Circuit,graphs,photon,emitter,emitter_flag_Gate,photon_flag_Gate,Store_Graphs,Store_Gates);

        return
        
    end
    
end

if length(potential_rows)>1

    %To avoid unnecessary phase update, spend some time to bitxor only the
    %Paulis, and see if now we have weight==1 on a single emitter.
    trashTab=Tab;
    trashTab(potential_rows(1),:)=bitxor(Tab(potential_rows(1),:),Tab(potential_rows(2),:));
    
    [emitter,emitter_flag_Gate] = check_for_single_emitter(trashTab,n,np,potential_rows(1));
    
    if ~isempty(emitter)
        
        disp(['Single Emitter #',int2str(emitter), ' was found to absorb photon #',int2str(photon),' w/o emitter gates.']) 
        
        discovered_emitter = true;
        Tab                = rowsum(Tab,n,potential_rows(1),potential_rows(2));
        
        if strcmpi([photon_flag_Gate{:}],'ZX') || strcmpi([photon_flag_Gate{:}],'XZ')

            photon_flag_Gate='Y';

        elseif strcmpi([photon_flag_Gate{:}],'ZY') || strcmpi([photon_flag_Gate{:}],'YZ')

            photon_flag_Gate='X';

        elseif strcmpi([photon_flag_Gate{:}],'XY') || strcmpi([photon_flag_Gate{:}],'YX')

            photon_flag_Gate='Z';

        end
        
        [Tab,Circuit,graphs]=PA_subroutine(n,Tab,Circuit,graphs,photon,emitter,...
                                           emitter_flag_Gate,photon_flag_Gate,...
                                           Store_Graphs,Store_Gates);
        
        %warning('Rowsum of 2 photonic rows gives PA for free.') %OK: Can happen because we do not do back-substitution in RREF.
        
        return
        
    end
    
end

%=== Search for emitter not entangled with others to absorb the photon ====
row_ids_emitters = Stabs_with_support_on_emitters(Tab,np,ne); %These rows can include emitters in product state.

if isempty(row_ids_emitters)
    
    return

else
    
    %Multiply photonic stab row with emitter row.
    for p=1:length(potential_rows)
       
        row1=potential_rows(p);
        
        for kk=1:length(row_ids_emitters)
            
            row2             = row_ids_emitters(kk);
            trashTab         = Tab;
            trashTab(row1,:) = bitxor(Tab(row1,:),Tab(row2,:));
            [emitter,~]      = check_for_single_emitter(trashTab,n,np,row1);
            
            if ~isempty(emitter) 
                
                testTab = rowsum(Tab,n,row1,row2);
                [new_rows,photon_flag_Gate,testTab] = detect_Stabs_start_from_photon(testTab,photon,n);

                for jj=1:length(new_rows) %Check again if we can find an emitter here:

                    [emitter,emitter_flag_Gate] = check_for_single_emitter(testTab,n,np,new_rows(jj));

                    if ~isempty(emitter)

                        discovered_emitter = true;
                        photon_flag_Gate   = photon_flag_Gate{jj};

                        %warning('In photon absorption w/o CNOT, multiplication of emitter with photonic stab gives PA for free.')

                        disp(['Emitter #',int2str(emitter), ' can absorb photon #',int2str(photon),' w/o emitter gates.']) 

                        Tab=testTab;
                        [Tab,Circuit,graphs]=PA_subroutine(n,Tab,Circuit,graphs,photon,emitter,...
                                                           emitter_flag_Gate,photon_flag_Gate,...
                                                           Store_Graphs,Store_Gates);

                        return

                    end             

                end
                
            end
            
        end
       
    end
    
end

if return_cond
    
    return
end


%-------------- Extra conditions ------------------------------------------

%Multiply the two photonic rows and then the row with the emitter row
if length(potential_rows)>1 && ~isempty(row_ids_emitters)
    
    testTab = rowsum(Tab,n,potential_rows(1),potential_rows(2));
    
    for l=1:length(row_ids_emitters)
        
        newTab = rowsum(testTab,n,potential_rows(1),row_ids_emitters(l));
        
        [new_rows,new_flag_gate,testTab] = detect_Stabs_start_from_photon(newTab,photon,n);
        
        for m=1:length(new_rows)
            
           [emitter,emitter_flag_Gate] = check_for_single_emitter(newTab,n,np,new_rows(m));
            
            if ~isempty(emitter)

                Tab=newTab;
                [Tab,Circuit,graphs]=PA_subroutine(n,Tab,...
                    Circuit,graphs,photon,emitter,emitter_flag_Gate,new_flag_gate{m},Store_Graphs,Store_Gates);            

                discovered_emitter=true;
                return

            end             
            
        end
        
    end
    
end


%----------- Try after Back-substitution ----------------------------------

if ~discovered_emitter
   
    fixedTab=Tab;
    Tab=Back_Subs_On_RREF_Tab(fixedTab,n,min(potential_rows));
    [potential_rows,photon_flag_Gate,Tab] = detect_Stabs_start_from_photon(Tab,photon,n);
    
    for jj=1:length(potential_rows) %Check for emitter not entangled with others to absorb the photon:

        [emitter,emitter_flag_Gate] = check_for_single_emitter(Tab,n,np,potential_rows(jj)); %Excludes emitters in product state from the row

        if ~isempty(emitter)

            discovered_emitter = true;
            photon_flag_Gate   = photon_flag_Gate{jj};

            disp(['Emitter #',int2str(emitter), ' can absorb photon #',int2str(photon),' w/o emitter gates.']) 

            [Tab,Circuit,graphs]=PA_subroutine(n,Tab,Circuit,graphs,photon,emitter,emitter_flag_Gate,photon_flag_Gate,Store_Graphs,Store_Gates);
            %warning('Entered Back Subs')
            return

        end

    end
    
end

if ~discovered_emitter
    return
end


end
