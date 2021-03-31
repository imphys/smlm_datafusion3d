function [newParticles] = OptimalSE3Graph(cost,particles,RR,filename)
%OPTIMALSE3GRAPH Rotate particles into common reference frame based on the
%optimal path through the cost function network
% INPUT:
%  cost: cost function value for the best alignment between all N
%  particles, presented in a upper triangular matrix. Unnormalized
%  particles: cell array of particles structs with .points field at least.
%  RR : 4x4 transformation matrix consisting of 3x3 rotation matrix and 3x1
%  translation vector
% OUTPUT:
%  newparticles : particles after applying all transformations
%
% (C) Copyright 2018-2020      
% Faculty of Applied Sciences
% Delft University of Technology
%
% Maarten Joosten, November 2020.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%    http://www.apache.org/licenses/LICENSE-2.0

% Step 1. Link particles together
A = cost;
N = length(particles);
I = zeros(N*(N-1)/2,2);
iter=1;
for ii=1:N-1
    for jj=(ii+1):N
        I(iter,1) = ii;
        I(iter,2) = jj;
        iter=iter+1;
    end
end
I = I';

% filename = '.'; 

f = figure;
imagesc(A)
colorbar;
map = [1,1,1;cool(1000)];
colormap(map)
grid on
set(gca,'fontsize',20)

LinkLog = cell(1); % Cell array that saves the links between particles
numlinks = zeros(N,1);
maxlinks=0;
princ = zeros(N);

% core loop, goes through cost matrix and links particles
iter=1;
while max(max(A)~=0)
    [i,j] = find(A==max(max(A)));
    if numlinks(i)==0 || numlinks(j)==0
        princ(i,j)=1;
    end
    numlinks(i) = numlinks(i)+1;
    numlinks(j) = numlinks(j)+1;
%     if i==2 || i==32 || i==42 | i==61 || j==2 || j==32 || j==42 || j==61
%         break
%     end

    NumEx = 0;
    idxC=[];
    for nC = 1:length(LinkLog)
        if sum(sum(i==LinkLog{nC})) || sum(sum(j==LinkLog{nC}))
            NumEx = NumEx+1;
            idxC = [idxC,nC];
        end
    end

    if NumEx==0
        LinkLog{length(LinkLog)+1} = [i,j];
        A(i,j)=0;
        A(j,i)=0;
        
    elseif NumEx==1
        LinkLog{idxC} = [LinkLog{idxC};i,j];
         
        A(i,j)=0;
        A(j,i)=0;
        tmp = LinkLog{idxC};
        if numlinks(i) > maxlinks 
            for ii=1:length(tmp)
                A(tmp(ii,1),i)=0; A(i,tmp(ii,1))=0;
                A(tmp(ii,2),i)=0; A(i,tmp(ii,2))=0;
            end
        end
        if numlinks(j) > maxlinks
            for ii=1:length(tmp)
                A(tmp(ii,1),j)=0; A(j,tmp(ii,1))=0;
                A(tmp(ii,2),j)=0; A(j,tmp(ii,2))=0;
            end
        end
        
    elseif NumEx==2    
        princ(i,j)=1;
        
        LinkLog{min(idxC)} = [LinkLog{min(idxC)};LinkLog{max(idxC)};i,j];
        LinkLog(max(idxC)) = [];

        A(i,j)=0;
        A(j,i)=0;
        
        tmp = LinkLog{min(idxC)};
        for ii=1:length(tmp)
            if numlinks(tmp(ii,1)) > maxlinks
                for jj=1:length(tmp)
                    A(tmp(ii,1),tmp(jj,1))=0;
%                     A(tmp(ii,2),tmp(jj,1))=0;
                    A(tmp(ii,1),tmp(jj,2))=0;
%                     A(tmp(ii,2),tmp(jj,2))=0;
                end
            end
            if numlinks(tmp(ii,2)) > maxlinks
                 for jj=1:length(tmp)
%                     A(tmp(ii,1),tmp(jj,1))=0;
                    A(tmp(ii,2),tmp(jj,1))=0;
%                     A(tmp(ii,1),tmp(jj,2))=0;
                    A(tmp(ii,2),tmp(jj,2))=0;
                end
            end
        end
    end
    
    % plot the updated cost matrix for fun
    imagesc(A)
    colorbar;
    map = [1,1,1;cool(1000)];
    colormap(map)
    grid on
    set(gca,'fontsize',20)
    drawnow

    iter=iter+1;    
end

imagesc(princ)
close(f)

% save network
LinkLog = [LinkLog{2},zeros(size(LinkLog{2},1),2)];
for ii=1:size(LinkLog,1)
    LinkLog(ii,3)=cost(LinkLog(ii,1),LinkLog(ii,2));
    LinkLog(ii,4)=princ(LinkLog(ii,1),LinkLog(ii,2));
end
LinkTable = array2table(LinkLog,'VariableNames',{'node_1','node_2','cost_value','isPrincipleConnection'});
writetable(LinkTable,[filename,'/network.txt']);

% step 2: build connection graphs: for each partilce 1:N find the path through the
% network to get to the reference particle
% build connection graphs

% ref = LinkLog(1,1); % set reference particle number to first particle in
% the chain

% use a variant of the 'ClosenessCentrality' to determine the most suitable
% reference particle
dist = cost+cost';
meandist = mean(dist);
[~,ref] = max(meandist);

[i,j] = find(LinkLog(:,1:2)==ref);

for ii=1:length(i)
    allpaths{ii} = [ref,LinkLog(i(ii),3-j(ii))];
end

CurNode=2;
while length(allpaths)~=(N-1)
    idxP=1;
    newpaths = [];
    for ii=1:length(allpaths)
        if length(allpaths{ii})<CurNode
            newpaths{idxP} = allpaths{ii};
            idxP=idxP+1;
        else
            [i,j] = find(LinkLog(:,1:2)==allpaths{ii}(CurNode));

            if length(i)==1
                newpaths{idxP} = allpaths{ii};
                idxP=idxP+1;
            else
                for jj=1:length(i)
                    if sum(LinkLog(i(jj),3-j(jj))==allpaths{ii})==0
                        newpaths{idxP} = [allpaths{ii},LinkLog(i(jj),3-j(jj))];
                        idxP=idxP+1;
                    else
                        newpaths{idxP} = allpaths{ii};
                        idxP=idxP+1;
                    end
                end       
            end        
        end
    end
    allpaths = newpaths;
    CurNode=CurNode+1;
end
allpaths=allpaths';

% perform rotations
sup=particles{ref}.points;
for ii=1:(N-1)
    cur_path = allpaths{ii};
    tmppar = particles{cur_path(end)}.points;
    
    for jj=fliplr(2:(length(cur_path)))
        if cur_path(jj) > cur_path(jj-1)
            % rotate one way
            idxI = find(I(1,:)==cur_path(jj-1) & I(2,:)==cur_path(jj));
            tmppar = (tmppar - RR(1:3,4,idxI)')*RR(1:3,1:3,idxI);
        else
            % rotate the other way
            idxI = find(I(1,:)==cur_path(jj) & I(2,:)==cur_path(jj-1));
            tmppar = tmppar*RR(1:3,1:3,idxI)' + RR(1:3,4,idxI)';        
        end 
    end
    
    newParticles{ii} = particles{cur_path(end)};
    newParticles{ii}.points = tmppar;
    newParticles{ii}.oldIdx = cur_path(end);
    
    sup = [sup;tmppar];
end
newParticles{N} = particles{ref};
newParticles{N}.oldIdx = ref;

% vis='on';
% 
% figure
% tmp = sup;
% wd = 3*std(tmp);
% scatter3(tmp(:,1),tmp(:,2),tmp(:,3),'.','markeredgecolor','red')
% xlim([-wd(1) wd(1)])
% ylim([-wd(2) wd(2)])
% zlim([-wd(3) wd(3)])
% axis square
% set(gcf,'units','normalized','outerposition',[0 0 0.5 1],...
% 'InvertHardCopy','off','color',[0 0 0],'visible',vis)
% set(gca,'Fontsize',28,...
% 'GridColor',[1 1 1],...
% 'Ycolor',[1 1 1],...
% 'Xcolor',[1 1 1],...
% 'Zcolor',[1 1 1],...
% 'color',[0 0 0])       
% xlabel('x [nm]','color',[1 1 1])
% ylabel('y [nm]','color',[1 1 1])
% zlabel('z [nm]','color',[1 1 1])

end

