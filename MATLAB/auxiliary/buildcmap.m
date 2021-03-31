function cmap = buildcmap(f1)
% Constructs a colormap corresponding to the amplitude of the
% one-dimensional input signal.
%
% INPUT:
% f1 is a n-by-1 array representing a response used to colorcode a  
%       scatterplot.
%
% OUTPUT:
% cmap is a n-by-3 array where cmap(i,:) is the rgb value of point i in in
%       a scatterplot.
%
% For more information, see showset.m.
%
% Written by Kye M Taylor, 2009.

nparts = min(100,length(f1)); % number of "bins" to split the range of f1 into
tmap   = hot(nparts+1); % chose jet so that hot colors represent the highest values of f1
tmap   = tmap(1:nparts,:); 


if islogical(f1)
    cmap   = zeros(length(f1),3);
    cmap(~f1,:) = repmat([0,0,1],nnz(~f1),1);
    cmap(f1,:) = repmat([255 127 0]/255,nnz(f1),1);
else


    f1 = f1/norm(f1,'inf');  % so function range in [-1,1]
    minf1  = min(f1);
    maxf1  = max(f1);

    bounds = linspace(minf1,maxf1,nparts);
    cmap   = zeros(length(f1),3);

    for p = 1:nparts-1
        idx = (f1>=bounds(p) & f1<bounds(p+1));
        cmap(idx,:) = repmat(tmap(p,:),nnz(idx),1);
    end
    idx = (f1>=bounds(p+1));
    cmap(idx,:) = repmat(tmap(nparts,:),nnz(idx),1);
end