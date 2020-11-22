% relative2absolute   lie-algebra averaging and consistency check of 
% relative transformation and computing the absolute transforms
%
% SYNOPSIS:
%   [initAlignedParticles, sup] = relative2absolute(subParticles, RR, I, N, nIterations, threshold, flagVisualizeSijHist)
%
% INPUT
%   subParticles
%       input unaligned particles
%   RR
%       N(N-1)/2 relative transformation
%   I 
%       2xN*(N-1)/2 connectivity matrix. particle_{I(1,i)} is registered to 
%       particle_{I(2,i)}
%   N 
%       number of particles    
%   nIterations
%       number of lie-algebra avg iterations
%   threshold 
%       threshold for removing inconsistent registration (!=3). In S_ij
%       histogram, the registration below 3-threshold are being removed in
%       the subsequent iterations.
%   flagVisualizeSijHist
%       flag for visualizing Sij histogram
%
% OUTPUT
%   initAlignedParticles
%       cell array of the aligned particles
%   sup
%       the superparticle
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

function [initAlignedParticles, sup] = relative2absolute(subParticles, RR, I, N, nIterations, threshold, flagVisualizeSijHist)

    % 2-1 Lie-algebraic averaging
    disp('Lie-algebraic averaging started!');

    % average relative rotations+translation (RR) to get the absolute ones (Mest)
    Mest = MeanSE3GraphFast(RR, I);

    IInew = I;
    RRnew = RR;
    Mestnew = Mest;

    for iter=1:nIterations

        Sij = zeros(4,4,N*(N-1)/2);
        trSij = zeros(1,N*(N-1)/2);
        uij = zeros(N*(N-1)/2,3);
        Saxis = zeros(N*(N-1)/2,3);
        Stheta = zeros(1,N*(N-1)/2);
        Snew = zeros(4,4,N*(N-1)/2);

        k = 1;
        kk=1;
        outlierID = [];
        inlierID = [];
        RRrefined = zeros(4,4,1);
        for i=1:N-1
            for j=i+1:N

                    RijRi = multiplySE3(RRnew(:,:,k), Mestnew(:,:,i));
                    Sij(:,:,k) = multiplySE3(transposeSE3(Mestnew(:,:,j)), RijRi);
                    trSij(k) = trace(Sij(:,:,k));
                    uij(k,:) = [Sij(3,2,k)-Sij(2,3,k) ...
                                Sij(1,3,k)-Sij(3,1,k) ...
                                Sij(2,1,k)-Sij(1,2,k)];
                    Stheta(k) = acos(0.5*(trSij(k)-1-1));
                    Saxis(k,:) = uij(k,:)./norm(uij(k,:));
                    Snew(1:3,1:3,k) = axang2rotm([Saxis(k,:) real(Stheta(k))]);
                    Snew(1:3,4,k) = Sij(1:3,4,k);
                    Snew(4,4,k) = 1;
                    curTrSij = trSij(k)-1;
                    if (curTrSij> 3-threshold)
                        RRnew(:,:,k) = RRnew(:,:,k);
                        inlierID = [inlierID;k];
                        Irefined(:,kk) = [i;j];
                        RRrefined(:,:,kk) = multiplySE3(Mestnew(:,:,j), transposeSE3(Mestnew(:,:,i))); 
                        kk = kk+1;
                    else
                          outlierID = [outlierID;k];
                    end
                    k = k+1;
            end
        end 

        RRnew(:,:,outlierID) = [];
        IInew(:,outlierID) = [];    
        Mestnew = MeanSE3GraphFast(RRnew, IInew);
        display(['lie averaging iteration ' num2str(iter)]);
        TraceSIJ(iter,:) = trSij-1;
        
        [initAlignedParticles, sup] = makeTemplate(Mestnew, subParticles, N);
        
        % visualize histogram and intermediate superparticles
        if flagVisualizeSijHist
            figure;histogram(trSij-1,20)
            title(['iter ' num2str(iter)]);
            xlabel('trace(S_{ij})-1')  
        
%             visualizeSMLM3D(sup,0.1,1);   
%             title(['iter ' num2str(iter)]);
        end

        IInew = I;
        RRnew = RR; 

    end

    disp('Lie-algebraic averaging is done!');
end