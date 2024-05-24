function isvalidword(m)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 24, 2024
%--------------------------------------------------------------------------
%
%Check if the word is a valid alternance word. If it is not valid, throw an
%error.
%Input m: the word

if (-1)^length(m)~=1
    error('Length of word is not even number.')
end

nodes = unique(m);

for jj=1:length(nodes)
    
    v    = nodes(jj);
    locs = find(m==v);
    
    if length(locs)~=2
        error('word does not have double occurrence of some node v')
    end
    
end

end
