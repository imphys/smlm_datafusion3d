% motion_graph   create a connected graph with N nodes
%
% SYNOPSIS:
%   idx = motion_graph(N)
%
% INPUT
%   N
%       The number of nodes
%
% OUTPUT
%   idx
%       The edges of the graph, a 2x(N-1) matrix with the node indices as
%       its elements
%
% NOTES
%   
%
% (C) Copyright 2018-2020      
% Faculty of Applied Sciences
% Delft University of Technology
%
% Hamidreza Heydarian, November 2020.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%    http://www.apache.org/licenses/LICENSE-2.0


function idx = motion_graph(N)

    % initial minimum spanning tree
    for i=1:N-1
        spanning_tree(1,i) = i;
        spanning_tree(2,i) = i+1;
    end
    
    idx = spanning_tree;
    
end