function RGS_clockwise_order_circuit

close all;

n              = 6;
node_ordering  = 1:2*n;
Store_Graphs   = false;
Store_Gates    = true;
Verify_Circuit = true;
return_cond    = false;
BackSubsOption = true;

Adj  = create_RGS(n,1:2*n,n,'Adjacency');
temp = Tableau_Class(Adj,'Adjacency');
temp = temp.Generation_Circuit_Heu1(node_ordering,Store_Graphs,...
                                  Store_Gates,BackSubsOption,...
                                  Verify_Circuit,return_cond);

Circ = temp.Photonic_Generation_Gate_Sequence;
CircOrder = 'backward';
np   = length(Adj);
ne   = temp.Emitters;
layer_shift=1;
Init_State_Option = '0';


draw_circuit(np,ne,Circ,CircOrder,layer_shift,Init_State_Option)


end