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
n   = 20;
Adj = create_random_graph(n); 

```

## Authors
Evangelia Takou

## License
This project is licensed under GPL-3.0 - see the [LICENSE](LICENSE) file for details.

