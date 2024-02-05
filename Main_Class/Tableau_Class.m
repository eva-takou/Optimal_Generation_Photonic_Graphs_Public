classdef Tableau_Class
%Class to simulate photonic graph state generation.
    
    properties
        
        Tableau                           %Target Tableau for photonic graph state generation
        Tableau_RREF                      %Augmented Tableau (photons+emitters) in RREF
        
        node_ordering                      %Ordering of nodes for photonic generation.
        Photonic_Generation_Gate_Sequence  %Circuit to generate the target graph.
        Photonic_Generation_Graph_Evol     %Evolution of the photonic generation in reverse.
        Emitters                           %Number of emitters to generate a given target graph, based on node_ordering
        Emitter_CNOT_count                 %Total emitters' CNOT count of the photonic generation circuit
        height                             %Height function of target photonic graph.
        Photonic_Generation_Circuit_Depth  %Depth of photonic generation circuit.
        Photonic_Generation_Gate_per_Depth %Photonic generation circuit, where gates are arranged per time-step. 
        
        
        Stab_String                       %Stabilizer string of Tableau
        
        VertexDegree                      %Degree of vertices
        Cliques                           %Degree of vertices
        
    end
    
    methods %Constructor method to initialize a Tableau
        
        function obj = Tableau_Class(inp,Option)   
        %Constructor requires input stabilizers in a string or the edgelist.
        %Option specifies which one is provided.
        
        switch Option
            
            case 'Stabs'

                if iscell(inp) && ischar(inp{1})
                
                S  = Stabs_String_to_Binary(inp);
                
                else %Otherwise given input is binary
                    
                    mustBeBinary(inp)
                    S = inp;
                
                end
                
                [n,cols]  = size(S);
                
                if cols~=2*n && cols~=2*n+1
                        
                    error('Stab array is of incorrect size.')
                    
                end
                
                
                %S could be  (n x 2n) or (n x 2n+1) -- if we also give a phase.                          
            
                if cols == 2*n
                
                    Tab = [S];
                    Tab = [Tab,zeros(2*n,1,'int8')];   %Add extra column of 0s for phases
                
                elseif cols== 2*n+1 %We have a column with phases as well
                
                    Tab = [S(:,1:2*n)];
                    Tab = [Tab,[zeros(n,1,'int8');S(:,2*n+1)]];
                    
                end
                
                
            
            case 'EdgeList'
            
                L = length(inp);
                n = max([inp{:}]);
            
                Sx = eye(n,'int8');
                Sz = zeros(n,n,'int8');
                
                for l=1:L
                    
                    edge = inp{l};
                    temp = zeros(n,n,'int8');
                    temp(edge(1),edge(2))=1;
                    Sz = Sz + temp+temp';
                    
                    
                end
                
                S   = [Sx,Sz];
                
                Tab = [S];    
                Tab = [Tab,zeros(2*n,1,'int8')];   %Add extra column
                
             
            
            case 'Adjacency'
                
                mustBeSimple(inp)
                
                n  = size(inp,1);
                Sz = inp;
                Sx = eye(n,'int8');
                
                S  = [Sx,Sz];
                
                Tab = [S];
                
                Tab = [Tab,zeros(n,1,'int8')];   %Add extra column
                
             
        end
        
        %mustBeStabGroup(Tab)
        obj.Tableau=Tab;
        
        end
        
    end
 
    methods 
        
        function obj=Tableau_To_String(obj,Option)
            
            switch Option
                
                
                case 'Tab'
                    
                    [s]=Tab_To_String(obj.Tableau);
                    
                case 'Tab_RREF'
                    
                    [s]=Tab_To_String(obj.Tableau_RREF);
                    

            end
            
                 
            obj.Stab_String=s;            
            
            
            
            
        end
        
    end

    methods %Apply Clifford gates or single qubit measurements 
        
        function obj=Apply_Clifford(obj,qubit,Oper,n)
            
            obj.Tableau=Clifford_Gate(obj.Tableau,qubit,Oper,n);
            
        end
        
        function [obj,outcome]=Apply_SingleQ_Meausurement(obj,qubit,basis)
            
            [obj.Tableau,outcome]=Measure_single_qubit(obj.Tableau,qubit,basis);
        
        end
        
    end
    
    
    methods %Photonic generation 

        function obj=reshuffle_nodes(obj,node_ordering)
        %Permute the ordering of qubits, according to input node_ordering.
        
        Tab = obj.Tableau;
        n   = (size(Tab,2)-1)/2;
        
        mustBeValidOrdering(node_ordering,n)
        
        Sx = Tab(:,1:n);
        Sz = Tab(:,n+1:2*n);
        
        %== Shuffle Stabs==
        
        Sx(:,1:n)=Sx(:,node_ordering);
        Sz(:,1:n)=Sz(:,node_ordering);
        
        Tab(:,1:n)     = Sx;
        Tab(:,n+1:2*n) = Sz;
        
        
        obj.Tableau=Tab;
            
            
        end
        
        function obj=Get_Emitters(obj,node_ordering)
        %Get the # of Emitters for a particular node ordering of the given graph.
        %The Tableau is updated based on the input ordering.
            
           n   = (size(obj.Tableau,2)-1)/2;
           obj = obj.reshuffle_nodes(node_ordering);
           
           obj.Tableau_RREF = RREF(obj.Tableau,n);
           obj.height       = height_function(obj.Tableau_RREF,n,false,[]); %The height function needs as input the target photonic generation Tableau.
           obj.Emitters     = max(obj.height);
            
        end

        %Photonic generation scheme w/o optimization levels (Naive)
        function obj=Generation_Circuit(obj,node_ordering,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit) 
        %Input: node_ordering: Ordering of photon emission.
        %       Store_Graphs: true or false (to store or not graph
        %       evolution)
        %       Store_Gates: true or false (to store or not the circuit)
        %       BackSubsOption: true or false (do backsubstitution in RREF
        %       or not)
        %       Verify_Circuit: true or false (to verify the circuit of the generation)
        
        Circuit = [];    
        obj     = obj.Get_Emitters(node_ordering);
        obj.node_ordering = node_ordering;
        
        ne  = obj.Emitters;
        np  = (size(obj.Tableau,2)-1)/2;
        n   = np+ne;    
        h   = obj.height;
        
        %===== The target photonic graph state and Tableau ==============
        Target_Tableau = obj.Tableau; 
        G0             = Get_Adjacency(Target_Tableau);
        
        graphs.Adjacency{1}  = G0;
        graphs.identifier{1} = 'Input';
        
        %== Augment the Tableau with emitters in |0> and put it in RREF ==
        
        workingTab = RREF(AugmentTableau(Target_Tableau,ne),n);
        
        %=== Begin the generation procedure (in reverse) =================
        
        for jj = np+1:-1:2

            disp('=================================================================')    
            disp(['Beginning iteration: ',num2str(jj-1)])            
            
            photon = jj-1;
            
            if jj<np+1 
                
                if BackSubsOption
                
                    workingTab = RREF_w_back_substitution(workingTab,n);
                    
                else
                    
                    workingTab = RREF(workingTab,n);
                    
                end
                
                h = height_function(workingTab,n,true,jj);
                
                
            end
            
            dh = h(jj)-h(jj-1); 
            
            if dh<0 %Need TRM--cannot absorb photon yet.
                
                [workingTab,Circuit,graphs]=time_reversed_measurement(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates);

            end

            
            [workingTab,Circuit,graphs,discovered_emitter,~]=photon_absorption_WO_CNOT(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates);
            
            
            if ~discovered_emitter
               
                [workingTab,Circuit,graphs]=photon_absorption_W_CNOT(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates);
                
            end
            
            if photon==1 %all photons were absorbed
            
                break
                
            end
            
        end
        
        workingTab                  = RREF(workingTab,n);
        [workingTab,Circuit,graphs] = disentangle_all_emitters(workingTab,np,ne,Circuit,graphs,Store_Graphs,Store_Gates);
        
        [workingTab,Circuit] = remove_redundant_Zs(workingTab,np,ne,Circuit,Store_Gates); %Convert the tableau to Zs:
        [~,Circuit] = fix_phases(workingTab,np,ne,Circuit,Store_Gates); %Fix phases:
       
        
        if Verify_Circuit && ~Store_Gates
           error('Requested to verify circuit, but gates were not stored.') 
        end
        
        if Verify_Circuit
            Verify_Quantum_Circuit(Circuit,n,ne,Target_Tableau)
        end
        
        obj.Photonic_Generation_Gate_Sequence  = Circuit;
        obj.Photonic_Generation_Graph_Evol     = graphs;
        
        %=== End of photonic generation ==================================
        
        end
        
        %Photonic generation scheme based on heuristics (Heuristics #1 and
        %#2)
        function [obj]=Generation_Circuit_Alt(obj,node_ordering,Store_Graphs,Store_Gates,BackSubsOption,EXTRA_OPT_LEVEL,Verify_Circuit) 
        %Input: node_ordering: Ordering of photon emission.
        %       Store_Graphs: true or false (to store or not graph
        %       evolution)
        %       Store_Gates: true or false (to store or not the circuit)
        %       BackSubsOption: true or false (do backsubstitution in RREF
        %       or not)
        %       EXTRA_OPT_LEVEL: true or false (true for Heuristics #2, false for Heuristics #1)
        %       Verify_Circuit: true or false (to verify the circuit of the generation)
        
        Circuit = [];    
        obj     = obj.Get_Emitters(node_ordering);
        obj.node_ordering = node_ordering;
        
        ne  = obj.Emitters;
        np  = (size(obj.Tableau,2)-1)/2;
        n   = np+ne;    
        h   = obj.height;

        
        %===== The target photonic graph state and Tableau ==============
        Target_Tableau = obj.Tableau; 
        G0             = Get_Adjacency(Target_Tableau);
        
        graphs.Adjacency{1}  = G0;
        graphs.identifier{1} = 'Input';
        
        %== Augment the Tableau with emitters in |0> and put it in RREF ==
        
        workingTab = RREF(AugmentTableau(Target_Tableau,ne),n);
        %mustBeValidTableau(workingTab);
        
        %=== Begin the generation procedure (in reverse) =================
        
        
        for jj = np+1:-1:2

            photon = jj-1;
            
            if jj<np+1 
               
                if BackSubsOption
                
                    workingTab = RREF_w_back_substitution(workingTab,n);
                    
                else
                    
                    workingTab = RREF(workingTab,n);
                    
                end
                
                h = height_function(workingTab,n,true,jj);
            
            end
            
            obj.Tableau_RREF=workingTab;
            %obj.Tableau_To_String('Tab_RREF')
            
            
            dh = h(jj)-h(jj-1); 
            
            if dh<0 %Need TRM--cannot absorb photon yet.
                
                [workingTab,Circuit,graphs]=time_reversed_measurement(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates);
                
            end

            obj.Tableau_RREF=workingTab;
            %obj.Tableau_To_String('Tab_RREF')
            
            [workingTab,Circuit,graphs,discovered_emitter,~]=photon_absorption_WO_CNOT(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates);
            
            if ~discovered_emitter
               
                %[workingTab,Circuit,graphs]=photon_absorption_W_CNOT_Test(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs);
                [workingTab,Circuit,graphs]=new_PA_w_CNOT(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates,EXTRA_OPT_LEVEL);
                
            end
            
            if photon==1 %all photons were absorbed
            
                break
                
            end
            
        end
        
        workingTab = RREF(workingTab,n);
        %mustBeValidTableau(workingTab)
        
        if Verify_Circuit && ~Store_Gates
           error('Requested to verify the circuit, but gates were not stored.') 
        end
            
        [workingTab,Circuit,graphs]=disentangle_all_emitters(workingTab,np,ne,Circuit,graphs,Store_Graphs,Store_Gates);
            
        if Verify_Circuit
            
            [workingTab,Circuit] = remove_redundant_Zs(workingTab,np,ne,Circuit,Store_Gates); %Convert the tableau to Zs:
            [workingTab,Circuit] = fix_phases(workingTab,np,ne,Circuit,Store_Gates); %Fix phases:
            Verify_Quantum_Circuit(Circuit,n,ne,Target_Tableau)
            
        end
       
        obj.Photonic_Generation_Gate_Sequence  = Circuit;
        obj.Photonic_Generation_Graph_Evol     = graphs;
        
        %=== End of photonic generation ==================================
        
        end
        
        %Old brute force
        function obj=Generation_Circuit_Opt_V0(obj,node_ordering,Store_Graphs,prune,avoid_subs_emitters,tryLC) 
            %Script for generation circuit based on Bikun's approach.
            %This script inspects all emitter choices by branching new choices as recursions.  
            %Input: Ordering of photon emission.
            %Circuit is in time reversed order.
            %Optimize for all emitter choices for photon absorption, by allowing as well 
            %row operations. 
            %This doesn't include yet the additional optimization for TRMs.

            Circuit           = [];    
            obj               = obj.Get_Emitters(node_ordering); 
            obj.node_ordering = node_ordering;

            ne  = obj.Emitters;
            np  = (size(obj.Tableau,2)-1)/2;
            n   = np+ne;    

            %===== The target photonic graph state and Tableau ==============
            Target_Tableau       = obj.Tableau; 
            G0                   = Get_Adjacency(Target_Tableau);
            graphs.Adjacency{1}  = G0;
            graphs.identifier{1} = 'Input';

            %== Augment the Tableau with emitters in |0> and put it in RREF ==

            workingTab = RREF(AugmentTableau(Target_Tableau,ne),n);
            mustBeValidTableau(workingTab);

            %=== Run the generation procedure (in reverse) ====================

            [OUT_Tab,OUT_Circ,OUT_graphs]=Gen_Circ_Opt_Emitters_FINAL(obj,workingTab,Circuit,graphs,np,ne,n,Store_Graphs,prune,avoid_subs_emitters,tryLC);

            %=================================================================

            %Now apply the disentangling procedure of emitters:

            LT        = length(OUT_Tab);
            CNOT_cnt  = zeros(1,LT);
            depth_cnt = zeros(1,LT);

            for jj=1:length(OUT_Circ)

                current_cnots(jj)=emitter_CNOTs(OUT_Circ{jj},ne,np);

            end

            parfor kk=1:LT

                workingTab = OUT_Tab{kk};
                Circuit    = OUT_Circ{kk};
                graphs     = OUT_graphs{kk};

                workingTab = RREF(workingTab,n);
                %mustBeValidTableau(workingTab)

                if ne>1 %Disentangle the emitters:

                    [workingTab,Circuit,graphs]=disentangle_all_emitters(workingTab,np,ne,Circuit,graphs,Store_Graphs);

                end 

                %mustBeValidTableau(workingTab)

                [workingTab,Circuit] = remove_redundant_Zs(workingTab,np,ne,Circuit); %Convert the tableau to Zs:
                [workingTab,Circuit] = fix_phases(workingTab,np,ne,Circuit); %Fix phases:

                %mustBeValidTableau(workingTab)
                Verify_Quantum_Circuit(Circuit,n,ne,Target_Tableau)


                OUT_Circ{kk}   = Circuit;
                OUT_graphs{kk} = graphs;
                %obj.Photonic_Generation_Gate_Sequence  = Circuit;
                %obj.Photonic_Generation_Graph_Evol     = graphs;

                CNOT_cnt(kk)  = emitter_CNOTs(Circuit,ne,np);
                depth_cnt(kk) = circuit_depth(Circuit,ne,np);

            end


            %We could make several choices of which circuit to pick
            %and we could choose to study all of the above.

            %CNOT_cnt
            %depth_cnt

            [~,indx] = min(CNOT_cnt);

            obj.Emitter_CNOT_count                = CNOT_cnt(indx);
            obj.Photonic_Generation_Circuit_Depth = depth_cnt(indx);
            obj.Photonic_Generation_Gate_Sequence = OUT_Circ{indx};
            obj.Photonic_Generation_Graph_Evol    = OUT_graphs{indx};


        end
        
        %Photonic generation scheme (Brute-force)
        function obj=Optimize_Generation_Circuit(obj,node_ordering,Store_Graphs,Store_Gates,prune,tryLC,LC_Rounds,Verify_Circuit,LCsTop) 
        %Input: node_ordering: Ordering of photon emission.
        %       Store_Graphs: true or false (to store or not graph
        %       evolution)
        %       Store_Gates: true or false (to store or not the circuit)
        %       prune: true or false to prune away choices
        %       tryLC: true or false to inspect LC degree of freedom
        %       LC_Rounds: 1,2,3,4 for rounds of LCs.
        %       LCsTop: true or false to allow some LCs after part of the
        %       graph has been consumed (for photon<=np-1)
        %       Verify_Circuit: true or false (to verify the circuit of the generation)

        Circuit           = [];    
        obj               = obj.Get_Emitters(node_ordering); 
        obj.node_ordering = node_ordering;
        
        ne  = obj.Emitters;
        np  = (size(obj.Tableau,2)-1)/2;
        n   = np+ne;    
        
        %===== The target photonic graph state and Tableau ==============
        Target_Tableau       = obj.Tableau; 
        G0                   = Get_Adjacency(Target_Tableau);
        graphs.Adjacency{1}  = G0;
        graphs.identifier{1} = 'Input';

        %== Augment the Tableau with emitters in |0> and put it in RREF ==

        workingTab = AugmentTableau(obj.Tableau_RREF,ne);
        
        %=== Run the generation procedure (in reverse) ====================

        [OUT_Tab,OUT_Circ,OUT_graphs]=Generation_Circuit_Opt(obj,workingTab,Circuit,graphs,np,ne,n,Store_Graphs,Store_Gates,prune,tryLC,LC_Rounds,LCsTop);
        
        
        %=================================================================
        
        %Now apply the disentangling procedure of emitters:

%         for jj=1:length(OUT_Circ)
%            
%             current_cnots(jj)=emitter_CNOTs(OUT_Circ{jj},ne,np);
%             
%         end
%         
%         %Do a prune procedure here as well:
%         if prune
%             
%             min_CNOTs=min(current_cnots);
%             indices=current_cnots<min_CNOTs+2;
%             current_cnots=current_cnots(indices);
%             OUT_Tab=OUT_Tab(indices);
%             OUT_Circ=OUT_Circ(indices);
%             OUT_graphs=OUT_graphs(indices);
%             
%         end
        
        LT = length(OUT_Tab);
        CNOT_cnt  = zeros(1,LT);
        
        if Verify_Circuit && ~Store_Gates
           
            error('Requested to verify circuit, but gates were not stored.')
            
        end
        
        for kk=1:LT

            workingTab = OUT_Tab{kk};
            Circuit    = OUT_Circ{kk};
            graphs     = OUT_graphs{kk};

            [workingTab,Circuit,graphs]=disentangle_all_emitters(workingTab,np,ne,Circuit,graphs,Store_Graphs,Store_Gates);
            

            if Verify_Circuit
                
                [workingTab,Circuit] = remove_redundant_Zs(workingTab,np,ne,Circuit,Store_Gates);
                [workingTab,Circuit] = fix_phases(workingTab,np,ne,Circuit,Store_Gates);
                
                Verify_Quantum_Circuit(Circuit,n,ne,Target_Tableau)
                
            end
            
            OUT_Circ{kk}   = Circuit;
            OUT_graphs{kk} = graphs;
            CNOT_cnt(kk)   = emitter_CNOTs(Circuit,ne,np);
            
        end
        
        [~,indx] = min(CNOT_cnt);
        
%         [OUT_Tab{indx},OUT_Circ{indx}] = remove_redundant_Zs(OUT_Tab{indx},np,ne,OUT_Circ{indx}); %Convert the tableau to Zs
%         [~,OUT_Circ{indx}] = fix_phases(OUT_Tab{indx},np,ne,OUT_Circ{indx}); %Fix phases
        
        obj.Emitter_CNOT_count                = CNOT_cnt(indx);
        obj.Photonic_Generation_Gate_Sequence = OUT_Circ{indx};
        obj.Photonic_Generation_Graph_Evol    = OUT_graphs{indx};
        
        
        end
        
        
        %Count the number of emitter CNOTs.
        function obj=Count_emitter_CNOTs(obj,node_ordering)
        %Input: node_ordering: emission order of photons.
            
            if isempty(obj.Photonic_Generation_Gate_Sequence)
               obj= obj.Generation_Circuit(node_ordering);
            end
            
            ne       = obj.Emitters;
            np       = (size(obj.Tableau,2)-1)/2;
            Circuit  = obj.Photonic_Generation_Gate_Sequence;
            
            CNOT_cnt = emitter_CNOTs(Circuit,ne,np);
            
            obj.Emitter_CNOT_count=CNOT_cnt;
            
        end
        
        %Count the circuit depth.
        function obj=Count_Circuit_Depth(obj)
            
            Circuit = obj.Photonic_Generation_Gate_Sequence;
            np      = (size(obj.Tableau,2)-1)/2;
            ne      = obj.Emitters;
            
            [depth,Gates_per_depth]=circuit_depth(Circuit,ne,np);
            
            obj.Photonic_Generation_Circuit_Depth  = depth;
            obj.Photonic_Generation_Gate_per_Depth = Gates_per_depth;
            
        end
        
    end
    
    
end


