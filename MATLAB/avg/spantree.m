% spantree   create a connected graph with N nodes
%
% SYNOPSIS:
%   edges = spantree(N)
%
% INPUT
%   N
%       The number of nodes
%
% OUTPUT
%   edges
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


function edges = spantree(N)

    nodeSet = 1:N;
    initIDX = randperm(N,1);
    initNode = nodeSet(initIDX);
    nodeSet(initIDX) = [];
    edges(1,1) = initNode;
    
    for i=1:N-1
        
        curIDX = randperm(N-i,1);
        curNode = nodeSet(curIDX);
        edges(2,i) = curNode;
        edges(1,i+1) = curNode;
        nodeSet(curIDX) = [];
        
    end       
    
    edges(:,N) = [];
    
end