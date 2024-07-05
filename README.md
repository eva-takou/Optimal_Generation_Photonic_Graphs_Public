# Optimal_Generation_Photonic_Graphs_Public
This package is a graph state simulator for preparing photonic graph states
from quantum emitters, with minimal resources. It contains optimizers for 
reducing the emitter-emitter CNOT gate count during the generation. 
The generation is simulated via the stabilizer tableau. 
This library includes extra functionalities such as: 
* recognizing circle graphs,
* recognizing local complement (LC) equivalence of graphs, 
* enumerating LC orbits of circle graphs, 
* generating the LC orbit of a graph.

This code is used 
to produce the results in the paper "Optimization complexity and resource 
minimization of emitter-based photonic graph state generation protocols", 
by E. Takou, E. Barnes, and S. E. Economou.

## Prerequisites
This package is self-contained and does not require additional packages
for performing the simulations. It has been developed on MATLAB R2021a, 
but should run without problems in any newer MATLAB version.

## Examples
### Simulate with the Naive optimizer
```
% Create input graph and its ordering
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

%Extract information about the graph and the circuit:
CNOTs   = temp.Emitter_CNOT_count;
ne      = temp.Emitters;
Circuit = temp.Photonic_Generation_Gate_Sequence;
```

## Authors
Evangelia Takou

## License
This project is licensed under GPL-3.0 - see the [LICENSE](LICENSE) file for details.

