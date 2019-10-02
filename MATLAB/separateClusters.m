function newSuperParticles = separateClusters(finalParticles, USE_GPU, nClust)

N = numel(finalParticles);      % the number of particles
scale = 0.1;                    % Gaussian scale
selfSim = zeros(1,N);           % self similarity of the particles
fvaldis = zeros(N,N);           % dissimilarity matrix
% nClust = 3;                     % the number of clusters

% compute the self similarities
for i=1:N
    selfSim(i) = GaussTransform(finalParticles{1,i}.points, finalParticles{1,i}.points, scale, USE_GPU);
end    

% compute the dissimilarities
k=1;
for i=1:N-1
    for j=i+1:N
        fvaldis(i,j) = selfSim(i) - GaussTransform(finalParticles{1,i}.points, finalParticles{1,j}.points, scale, USE_GPU);
        k=k+1;
    end
end

Y = mdscale(fvaldis+fvaldis',2);
idxxx = kmeans(Y, nClust);
figure
c = 'rgbymcwk';
gscatter(Y(:,1),Y(:,2),idxxx,c(1:nClust))

newSuperParticles = cell(1,nClust);

for j=1:nClust
    ID = find(idxxx==j);
    for i=1:numel(ID)
        newSuperParticles{1,j} = [newSuperParticles{1,j};finalParticles{1,ID(i)}.points];
    end
end

end