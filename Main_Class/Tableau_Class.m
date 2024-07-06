classdef Tableau_Class
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 6, 2024
%--------------------------------------------------------------------------
%Class to simulate photonic graph state generation from quantum emitters.

    properties
        
        Tableau                            %Target Tableau for photonic graph state generation
        Tableau_RREF                       %Augmented Tableau (photons+emitters) in RREF
        Destabilizer_Tableau               %Tableau of destabilizer operators
        node_ordering                      %Ordering of nodes for photonic generation.
        Photonic_Generation_Gate_Sequence  %Circuit to generate the target graph.
        Photonic_Generation_Graph_Evol     %Evolution of the photonic generation in reverse.
        Emitters                           %Number of emitters to generate a given target graph, based on node_ordering
        Emitter_CNOT_count                 %Total emitters' CNOT count of the photonic generation circuit
        height                             %Height function of target photonic graph.
        Photonic_Generation_Circuit_Depth  %Depth of photonic generation circuit.
        Photonic_Generation_Gate_per_Depth %Photonic generation circuit, where gates are arranged per time-step.         
        Stab_String                        %Stabilizer string of Tableau
                
    end
    
    methods %Constructor method to initialize a Tableau
        
        function obj = Tableau_Class(inp,Option)   
        %Arguments: inp: n x 2n Stab array (binary or cell of Pauli strings as chars),
        %or cell array of Edgelist, or Adjacency matrix
        %        Option: 'Stabs' or 'EdgeList' or 'Adjacency' to indicate
        %                the input
        
        switch Option
            
            case 'Stabs'

                if iscell(inp) && ischar(inp{1})
                
                    S  = Stabs_String_to_Binary(inp);
                
                else %Otherwise given input is binary
                    
                    mustBeBinary(inp)
                    S = inp;
                
                end
                
                [n,cols] = size(S);
                
                if cols~=2*n 
                        
                    error('Stab array is of incorrect size.')
                    
                end
            
                Tab = S;
                Tab = [Tab,zeros(n,1,'int8')];   %Add extra column of 0s for phases
            
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
                Tab = S;    
                Tab = [Tab,zeros(n,1,'int8')];   %Add extra column
            
            case 'Adjacency'
                
                mustBeSimple(inp)
                
                n  = size(inp,1);
                Sz = int8(inp);
                Sx = eye(n,'int8');
                
                S   = [Sx,Sz];
                Tab = S;
                Tab = [Tab,zeros(n,1,'int8')];   %Add extra column for phase vector
                
%                 Dz  = eye(n,'int8');
%                 Dx  = zeros(n,n,'int8');
%                 D   = [Dx,Dz];
%                 D   = [D,zeros(n,1)];
%                 obj.Destabilizer_Tableau = D;
                
        end
        
        mustBeStabGroup(S)
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
        
        function obj=Apply_Clifford(obj,qubit,Oper,n,varargin)
        %Apply a Clifford gate on the Tableau.
        %Inputs: qubit: qubit index for single qubit gate or 2 qubit indices 
        %for 2-qubit gate.
        %         Oper: 'H', or 'P', or 'Pdag', or 'CNOT', or 'CZ', or 'X', 
        %               or 'Y', or 'Z'
        %          n: # of qubits represented by the Tableau
        
            obj.Tableau=Clifford_Gate(obj.Tableau,qubit,Oper,n);
            
            if nargin>4 %We request update on destabilizers too
                
                obj.Destabilizer_Tableau = Clifford_Gate(varargin{1},qubit,Oper,n);
                
            end
            
            
        end
        
        function [obj,outcome,type_of_outcome]=Apply_SingleQ_Meausurement(obj,qubit,basis) %varargin
        %Apply a single qubit measurement on the stabilizer Tableau.
        %Inputs: qubit: qubit index to apply the Measurement
        %        basis: 'X' or 'Y' or 'Z'
            
            [obj.Tableau,outcome,type_of_outcome]=Measure_single_qubit(obj.Tableau,qubit,basis);
            
        end
        
    end
    
    methods %Photonic generation 

        function obj=reshuffle_nodes(obj,node_ordering)
        %Permute the ordering of qubits, according to input node_ordering.
        %Input: node_ordering: the new emission ordering of the photons
        
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
        %Input: node_ordering: the emission ordering of the photons
            
           n   = (size(obj.Tableau,2)-1)/2;
           obj = obj.reshuffle_nodes(node_ordering);
           
           obj.Tableau_RREF = RREF(obj.Tableau,n);
           obj.height       = height_function(obj.Tableau_RREF,n,false,[]); %The height function needs as input the target photonic generation Tableau.
           obj.Emitters     = max(obj.height);
            
        end

        function obj=Generation_Circuit(obj,node_ordering,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond) 
        %Naive implementation of the photonic generation scheme.
        %Input: node_ordering: Emission ordering of photons.
        %       Store_Graphs: true or false (for graph evolution)
        %       Store_Gates: true or false (to store or not the circuit)
        %       BackSubsOption: true or false (do backsubstitution in RREF
        %       or not). Naive should have the option set to false
        %       Verify_Circuit: true or false (to verify the circuit in the end)
        %       return_cond: true for early exit in free PA inspection,
        %       false for exhausting all checks for free PA.
        
        Circuit = [];    
        obj     = obj.Get_Emitters(node_ordering);
        obj.node_ordering = node_ordering;
        
        ne  = obj.Emitters;
        np  = (size(obj.Tableau,2)-1)/2;
        n   = np+ne;    
        h   = obj.height;
        
        %===== The target photonic graph state and Tableau ==============
        Target_Tableau = obj.Tableau; 
        
        %== Augment the Tableau with emitters in |0> and put it in RREF ==
        
        workingTab = RREF(AugmentTableau(Target_Tableau,ne),n);
        
        graphs.Adjacency{1}  = Get_Adjacency(workingTab);
        graphs.identifier{1} = 'Input';
        %=== Begin the generation procedure (in reverse) =================
        
        for jj = np+1:-1:2

            disp('=================================================================')    
            disp(['Beginning iteration: ',int2str(jj-1)])            
            
            photon = jj-1;
            
            if jj<np+1 
                 
                workingTab = RREF(workingTab,n);
                 
                if BackSubsOption
                
                    workingTab=Back_Subs_On_RREF_Tab(workingTab,n,[]);
                    
                end
                
                h = height_function(workingTab,n,true,jj);
                
                
            end
            
            dh = h(jj)-h(jj-1); 
            
            if dh<0 %Need TRM--cannot absorb photon yet.
                
                
                [workingTab,Circuit,graphs]=time_reversed_measurement(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates);

            end

            [workingTab,Circuit,graphs,discovered_emitter,~]=...
                photon_absorption_WO_CNOT(workingTab,np,ne,photon,Circuit,graphs,...
                Store_Graphs,Store_Gates,return_cond);
            
            
            if ~discovered_emitter
               
                [workingTab,Circuit,graphs]=photon_absorption_W_CNOT(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates);
                
            end
            
            if photon==1 %all photons were absorbed
            
                break
                
            end
            
        end
        
        workingTab                  = RREF(workingTab,n);
        [workingTab,Circuit,graphs] = disentangle_all_emitters(workingTab,np,ne,Circuit,graphs,Store_Graphs,Store_Gates,BackSubsOption);
        
        if Store_Gates
        
            [workingTab,Circuit] = remove_redundant_Zs(workingTab,np,ne,Circuit,Store_Gates); %Convert the tableau to Zs
            [~,Circuit]          = fix_phases(workingTab,np,ne,Circuit,Store_Gates); %Fix phases

        end
        
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

        
        function [obj]=Generation_Circuit_Heu1(obj,node_ordering,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond,varargin) 
        %Implementation of the photonic generation scheme with Heuristics
        %#1.
        %Input: node_ordering: Emission ordering of photons.
        %       Store_Graphs: true or false (for graph evolution)
        %       Store_Gates: true or false (to store or not the circuit)
        %       BackSubsOption: true or false (do backsubstitution in RREF
        %       or not)
        %       Verify_Circuit: true or false (to verify the circuit in the end)
        %       return_cond: true for early exit in free PA inspection,
        %       false for exhausting all checks for free PA.
       
        Circuit = [];    
        obj     = obj.Get_Emitters(node_ordering);
        obj.node_ordering = node_ordering;
        
        ne  = obj.Emitters;
        np  = (size(obj.Tableau,2)-1)/2;
        n   = np+ne;    
        h   = obj.height;

        %===== The target photonic graph state and Tableau ==============
        Target_Tableau = obj.Tableau; 
        
        
        %== Augment the Tableau with emitters in |0> and put it in RREF ==
        
        workingTab = RREF(AugmentTableau(Target_Tableau,ne),n);
        graphs.Adjacency{1}  = Get_Adjacency(workingTab);
        graphs.identifier{1} = 'Input';
        %=== Begin the generation procedure (in reverse) =================
        
        for jj = np+1:-1:2

            photon = jj-1;
            
            if jj<np+1 
               
                workingTab = RREF(workingTab,n);
                
                if BackSubsOption
                
                    workingTab = Back_Subs_On_RREF_Tab(workingTab,n,[]);
                    
                    
                end
                
                h = height_function(workingTab,n,true,jj);
            
            end
            
            dh = h(jj)-h(jj-1); 
            
            if dh<0 %Need TRM--cannot absorb photon yet.
                
                [workingTab,Circuit,graphs]=time_reversed_measurement(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates);
                
            end

            [workingTab,Circuit,graphs,discovered_emitter,~]=photon_absorption_WO_CNOT(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates,return_cond);
            
            if ~discovered_emitter
               
                [workingTab,Circuit,graphs]=new_PA_w_CNOT_Heu1(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates,return_cond,varargin);
                
            end
            
            if photon==1 %all photons were absorbed
            
                break
                
            end
            
        end
        
        workingTab = RREF(workingTab,n);
        
        if Verify_Circuit && ~Store_Gates 
           
            error('Requested to verify the circuit, but gates were not stored.') 
        
        elseif ~Verify_Circuit && Store_Gates
            
            warning('Turn Verify_Circuit to true, to store potential final gates.') 
            
        end
            
        [workingTab,Circuit,graphs]=disentangle_all_emitters(workingTab,np,ne,Circuit,graphs,Store_Graphs,Store_Gates,BackSubsOption);
        
        if Store_Gates
        
            [workingTab,Circuit] = remove_redundant_Zs(workingTab,np,ne,Circuit,Store_Gates); %Convert the tableau to Zs
            [~,Circuit]          = fix_phases(workingTab,np,ne,Circuit,Store_Gates); %Fix phases

        end        
        
        if Verify_Circuit
            
            Verify_Quantum_Circuit(Circuit,n,ne,Target_Tableau)
            
        end
       
        obj.Photonic_Generation_Gate_Sequence  = Circuit;
        obj.Photonic_Generation_Graph_Evol     = graphs;
        
        %=== End of photonic generation ==================================
        
        end
        
        
        function [obj]=Generation_Circuit_Heu2(obj,node_ordering,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,EXTRA_OPT_LEVEL,return_cond,...
                                              emitter_cutoff0,future_step,recurse_further,varargin) 
        %Implementation of the photonic generation scheme with Heuristics
        %#2.
        %Input: node_ordering: Emission ordering of photons.
        %       Store_Graphs: true or false (for graph evolution)
        %       Store_Gates: true or false (to store or not the circuit)
        %       BackSubsOption: true or false (do backsubstitution in RREF
        %       or not)
        %       Verify_Circuit: true or false (to verify the circuit in the end)
        %       EXTRA_OPT_LEVEL: true or false to enter the Heu2
        %       optimization
        %       return_cond: true for early exit in free PA inspection,
        %       false for exhausting all checks for free PA.
        %       emitter_cutoff0: max # of emitters to inspect per photon
        %       absorption
        %       future_step: # of future steps to inspect before making an
        %       emitter decision
        %       recurse_further: true to enable the recursions, false to
        %       turn them off
        
        Circuit = [];    
        obj     = obj.Get_Emitters(node_ordering);
        obj.node_ordering = node_ordering;
        
        ne  = obj.Emitters;
        np  = (size(obj.Tableau,2)-1)/2;
        n   = np+ne;    
        h   = obj.height;

        %===== The target photonic graph state and Tableau ==============
        Target_Tableau = obj.Tableau; 
        
        %== Augment the Tableau with emitters in |0> and put it in RREF ==
        
        workingTab = RREF(AugmentTableau(Target_Tableau,ne),n);
        graphs.Adjacency{1}  = Get_Adjacency(workingTab);
        graphs.identifier{1} = 'Input';
        
        %=== Begin the generation procedure (in reverse) =================
        
        for jj = np+1:-1:2

            photon = jj-1;
            
            if jj<np+1 
               
                workingTab = RREF(workingTab,n);
                
                if BackSubsOption
                
                    workingTab = Back_Subs_On_RREF_Tab(workingTab,n,[]);
                    
                end
                
                h = height_function(workingTab,n,true,jj);
            
            end
            
            dh = h(jj)-h(jj-1); 
            
            if dh<0 %Need TRM--cannot absorb photon yet.
                
                [workingTab,Circuit,graphs]=time_reversed_measurement(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates);
                
            end

            [workingTab,Circuit,graphs,discovered_emitter,~]=photon_absorption_WO_CNOT(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates,return_cond);
            
            if ~discovered_emitter
               
                
                [workingTab,Circuit,graphs]=new_PA_w_CNOT_Heu2(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates,...
                                                               EXTRA_OPT_LEVEL,return_cond,emitter_cutoff0,future_step,recurse_further,BackSubsOption,varargin);
              
            end
            
            if photon==1 %all photons were absorbed
            
                break
                
            end
            
        end
        
        workingTab = RREF(workingTab,n);
        
        if Verify_Circuit && ~Store_Gates
           
            error('Requested to verify the circuit, but gates were not stored.') 
        
        elseif ~Verify_Circuit && Store_Gates
            
            warning('Turn Verify_Circuit to true, to store potential final gates.') 
            
        end
            
        [workingTab,Circuit,graphs]=disentangle_all_emitters(workingTab,np,ne,Circuit,graphs,Store_Graphs,Store_Gates,BackSubsOption);
        
        if Store_Gates
        
            [workingTab,Circuit] = remove_redundant_Zs(workingTab,np,ne,Circuit,Store_Gates); %Convert the tableau to Zs
            [~,Circuit]          = fix_phases(workingTab,np,ne,Circuit,Store_Gates); %Fix phases

        end        
        
        if Verify_Circuit 
            
            Verify_Quantum_Circuit(Circuit,n,ne,Target_Tableau)
            
        end
       
        obj.Photonic_Generation_Gate_Sequence  = Circuit;
        obj.Photonic_Generation_Graph_Evol     = graphs;
        
        %=== End of photonic generation ==================================
        
        end
        
        function obj=Optimize_Generation_Circuit(obj,node_ordering,Store_Graphs,Store_Gates,prune,tryLC,LC_Rounds,Verify_Circuit,LCsTop,BackSubsOption,return_cond) 
        %Bruteforce optimization of the photonic generation scheme.
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
        %       BackSubsOption: true or false to allow backsubstitution
        %       return_cond: true for early exit in PA, false to inspect
        %       all conditions for free PA

        Circuit           = [];    
        obj               = obj.Get_Emitters(node_ordering); 
        obj.node_ordering = node_ordering;
        
        ne  = obj.Emitters;
        np  = (size(obj.Tableau,2)-1)/2;
        n   = np+ne;    
        
        %===== The target photonic graph state and Tableau ==============
        Target_Tableau       = obj.Tableau; 
        
        %== Augment the Tableau with emitters in |0> and put it in RREF ==

        workingTab = AugmentTableau(obj.Tableau_RREF,ne);
        graphs.Adjacency{1}  = Get_Adjacency(workingTab);
        graphs.identifier{1} = 'Input';
        
        %=== Run the generation procedure (in reverse) ====================

        [OUT_Tab,OUT_Circ,OUT_graphs]=Generation_Circuit_Opt(workingTab,...
            Circuit,graphs,np,ne,n,...
            Store_Graphs,Store_Gates,prune,tryLC,...
            LC_Rounds,LCsTop,BackSubsOption,return_cond);
        
        %=================================================================
        
        LT = length(OUT_Tab);
        CNOT_cnt  = zeros(1,LT);
        
        if Verify_Circuit && ~Store_Gates
           
            error('Requested to verify circuit, but gates were not stored.')
            
        end
        
        %Now apply the disentangling procedure of emitters:
        
        for kk=1:LT

            workingTab = OUT_Tab{kk};
            Circuit    = OUT_Circ{kk};
            graphs     = OUT_graphs{kk};

            [workingTab,Circuit,graphs]=disentangle_all_emitters(workingTab,np,ne,Circuit,graphs,Store_Graphs,Store_Gates,BackSubsOption);
            

            if  Store_Gates
                
                [workingTab,Circuit] = remove_redundant_Zs(workingTab,np,ne,Circuit,Store_Gates);
                [~,Circuit] = fix_phases(workingTab,np,ne,Circuit,Store_Gates);
                
                if Verify_Circuit
                    Verify_Quantum_Circuit(Circuit,n,ne,Target_Tableau)
                end
                
            end
            
            OUT_Circ{kk}   = Circuit;
            OUT_graphs{kk} = graphs;
            CNOT_cnt(kk)   = emitter_CNOTs(Circuit);
            
        end
        
        [~,indx] = min(CNOT_cnt);
        
        obj.Emitter_CNOT_count                = CNOT_cnt(indx);
        obj.Photonic_Generation_Gate_Sequence = OUT_Circ{indx};
        obj.Photonic_Generation_Graph_Evol    = OUT_graphs{indx};
        
        end
        
        function obj=Count_emitter_CNOTs(obj)
        %Count the number of emitter CNOTs.
            
            Circuit                = obj.Photonic_Generation_Gate_Sequence;
            CNOT_cnt               = emitter_CNOTs(Circuit);
            obj.Emitter_CNOT_count = CNOT_cnt;
            
        end
        
        function obj=Count_Circuit_Depth(obj)
        %Count the circuit depth.  
  
            Circuit = obj.Photonic_Generation_Gate_Sequence;
            np      = (size(obj.Tableau,2)-1)/2;
            ne      = obj.Emitters;
            
            [depth,Gates_per_depth]=circuit_depth(Circuit,ne,np);
            
            obj.Photonic_Generation_Circuit_Depth  = depth;
            obj.Photonic_Generation_Gate_per_Depth = Gates_per_depth;
            
        end
        
    end
    
end