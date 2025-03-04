# Optimal_Generation_Photonic_Graphs_Public

<img src="/images/Encoded_RGS_V2.png" width="250"/>

This package is a graph state simulator for preparing photonic graph states
from quantum emitters, with minimal resources. It contains optimizers for 
reducing the number of emitter-emitter CNOT gates of the Clifford circuit. 
The generation is simulated in a backwards manner (from target graph to product state)
via the stabilizer tableau. 
This library includes extra functionalities such as: 
* recognizing circle graphs,
* recognizing local complement (LC) equivalence of graphs, 
* enumerating LC orbits of circle graphs, 
* generating the LC orbit of a graph.


This code is used 
to produce the results of the paper "Optimization complexity and resource 
minimization of emitter-based photonic graph state generation protocols", 
by E. Takou, E. Barnes, and S. E. Economou.

## Prerequisites
The package is self-contained and does not require additional packages
for performing the simulations. It has been developed on MATLAB R2021a, 
but should run without problems in any newer MATLAB version.

## Installation

1. Download the package to a local folder.
2. Run MATLAB and add the package to the path.
3. Run some demos.

## Examples
### Simulate with the Naive optimizer
```
% Create photonic graph and its emission ordering
np            = 20; %# of photons
node_ordering = 1:np;
Adj           = create_random_graph(np); 

% Set options for the simulator
Store_Graphs   = false;
Store_Gates    = true;
Verify_Circuit = true;

% Default options for the Naive optimizer
BackSubsOption = false; 
return_cond    = true;  

% Give the graph as an input to the Tableau Class simulator
obj = Tableau_Class(Adj,'Adjacency'); 
obj = obj.Generation_Circuit(node_ordering,Store_Graphs,...
                             Store_Gates,BackSubsOption,...
                             Verify_Circuit,return_cond)
obj = obj.Count_emitter_CNOTs;
```

### Extract info about the circuit
```
CNOTs   = obj.Emitter_CNOT_count;
ne      = obj.Emitters;
Circuit = obj.Photonic_Generation_Gate_Sequence; 
```
### Simplify the circuit
```
% Set options for simplification
ConvertToCZ         = false;
pass_X_photons      = true;
pass_emitter_Paulis = true;
Init_State_Option   = '0';
monitor_update      = true; %to see the update in real time
pause_time          = 0.1;  %in seconds (delay to plot next update)
fignum              = 1;    %# of figure to plot

circuitOrder = 'backward'; %generation scheme returns it as backward
Circuit      = Simplify_Circuit(Circuit,np,ne,circuitOrder,...
                                ConvertToCZ,pass_X_photons,pass_emitter_Paulis,...
                                Init_State_Option,monitor_update,pause_time,fignum)
```
### Put the circuit to forward order
```
Circuit = put_circuit_forward_order(Circuit);
```

### Plot the circuit
```
circuit_order     = 'forward';
layer_shift       = 1; %spacing of gates in visualization
Init_State_Option = '0'; %qubits start from |0>
draw_circuit(np,ne,Circuit,circuit_order,layer_shift,Init_State_Option)
```
### Simulate with Heuristics #1 optimizer
```
% The following options can be changed to true or false
BackSubsOption = true;
return_cond    = false;

% Apply the Heuristics #1 generation protocol
obj = obj.Generation_Circuit_Heu1(node_ordering,Store_Graphs,Store_Gates,...
                                  BackSubsOption,Verify_Circuit,return_cond);
```

## References
1. Circle graph theory: <https://link.springer.com/article/10.1007/BF02579301>
2. LC equivalence: <https://www.sciencedirect.com/science/article/pii/0012365X9390357Y>, <https://journals.aps.org/pra/abstract/10.1103/PhysRevA.70.034302>
3. Enumeration of LC orbit: <https://www.sciencedirect.com/science/article/pii/0012365X9390357Y>, 
<https://arxiv.org/abs/1907.08024>
3. Stabilizer Tableau theory: <https://arxiv.org/abs/quant-ph/0406196>
4. Original non-optimized photonic generation algorithm: <https://www.nature.com/articles/s41534-022-00522-6>
5. Optimized photonic generation algorithms developed here: <https://arxiv.org/pdf/2407.15777>

## Authors
Evangelia Takou

## License
This project is licensed under GNU GPL-3.0 - see the [LICENSE](LICENSE) file for details.

