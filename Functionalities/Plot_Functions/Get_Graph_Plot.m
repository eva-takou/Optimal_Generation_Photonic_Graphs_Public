function Get_Graph_Plot(Gamma,layoutOpt,nodenames,nodes_other_color,...
                        node_incident_edges)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 3, 2024
%--------------------------------------------------------------------------
%
%Function to plot a single graph. 
%Inputs: Gamma: Adjacency matrix
%        layoutOpt: 'auto', 'force', 'circle' etc, see: plot(graph) matlab        
%        nodenames: a cell array of characters or an array of doubles that
%        contains the names of the nodes.
%        nodes_other_color: a cell of struct. Each stuct that has .name and .color. Used to
%        give a different color to the nodes_other_color.names.
%        node_incident_edges: to color differently some subset of edges,
%        incident to a node. Cell array of structs.

G     = graph(Gamma);
h     = plot(G,'layout',layoutOpt);


h.MarkerSize   = 10;
h.NodeFontSize = 18;
h.NodeFontName = 'Micrososft Sans Serif';
h.LineWidth    = 3;
h.NodeColor    = [0,0,0]; %All nodes black by default.
h.EdgeColor    = [16 78 139]/255; %All edge connections light blue-gray by default.

set(gcf,'color','w')
set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')

%Define the nodenames if input is provided--otherwise by default it follows
%numerical naming 1,2,... of nodes.
if ~isempty(nodenames)
    
    if isa(nodenames,'double')
        
        
        names = cell(1,length(nodenames));
        
        for jj=1:length(nodenames)
           names{jj} =num2str(nodenames(jj));
        end
        
        
    elseif isa(nodenames{1},'char')
        
        names = nodenames;
        
    else
        
        error('Either provide a numerical array or a cell of characters for the node labels.')
        
    end
   
    h.NodeLabel = names;
    
end

%Define different colors for some nodes depending on the node_colors

if ~isempty(nodes_other_color)
   
    if ~isa(nodes_other_color,'cell')
        error('Provide cell array of nodes that contains struct with the fields .names and .color.')
    end
    
    for ll=1:length(nodes_other_color)
        
        highlight(h,nodes_other_color{ll}.names,'NodeColor',nodes_other_color{ll}.color)
    end
    
end

if ~isempty(node_incident_edges)
   
    if ~isa(node_incident_edges,'cell')
       
        error('Provide cell array of nodes that contains struct with the fields .names and .colors.')
        
    end
    
    for ll=1:length(node_incident_edges)
   
        node_name = node_incident_edges{ll}.name;
        edge_color = node_incident_edges{ll}.color;
        
        highlight(h,node_name,neighbors(G,node_name),'EdgeColor',edge_color)
        
    end
    
end


end