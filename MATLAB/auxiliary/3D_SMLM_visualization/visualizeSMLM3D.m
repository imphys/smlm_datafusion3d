function density = visualizeSMLM3D(data, sigma, show)

    if nargin < 3
        show = 1;
    end
    % add Fast Gauss Transform path (change to your local directory)
    addpath(genpath('FGT'));

%     tic

    N = size(data,1);
    % sigma  = 0.025;                                           % the choice of sigma depends on the dataset

    q = ones(1,N);                                          % weight for each point, set to 1 as default
    epsilon = 1e-4;                                         % tolerance for the accuracy of Gauss Transform approximation
    density = figtree( data', sigma, q, data', epsilon)/N;  % density is the color used in scatter plot   

    if show
        figure;
        % visulaization
        scatter3(data(:,1),data(:,2), data(:,3), 1, density, '.');
        colormap(hot);
        set(gca,'Color','k')                                    % the background should be black for the hot colormap
        axis equal, axis square
    end

%     toc

end