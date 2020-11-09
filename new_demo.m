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

% demo of particle averaging code using the fast network approach

% settings and misc parameters
N = 10;                          % number of particles for alignment
USE_SYMMETRY = 0;                % flag for imposing symmetry prior knowledge
M1=[];                             % not implemented
iter = 3;                           % number of iterations for one-2-all registration
CCD_pixelsize = 130;        % pixelsize in nm/pixel
nIteration=8;                   % iterations for pairfittig for realignment
tolerance = 1.5;            % tolerance level for the deviation of the uncertainty of localisations
vis='off';                  % flag determining if plots will be visible
PLOT_COST_LANDSCAPE=false;  % flag determinig if scale_sweep plots cost vs scale
numsample = 6;             % pairs of particles used for scale_sweep
initAng = 8;                % number of initialisation angles per degree of freedom during registration
delay = 0.1;                % delay used when saving .gif figures

% CPU/GPU settings
USE_GPU_GAUSSTRANSFORM = true;
USE_GPU_EXPDIST = true;
USE_GPU = true;

datafile = 'data/example_data.mat';
outputdir = '.';

addpath(genpath('MATLAB'))
addpath(genpath('build/mex'))
addpath(genpath('build/figtree/src/mex'))

%%

% all intermediate steps of interest and the final reconstruction are saved
% to one structure
result = struct();

load(datafile)

% perform scale sweep to find optimal scale for alignment
disp('starting scale sweep')
[optimal_scale,scales_vec,cost_log,idxP] = scale_sweep(particles,numsample,PLOT_COST_LANDSCAPE);

% select scales for alignment
[~,idxS] = find(mean(cost_log,1)==max(mean(cost_log,1)));
scale = [scales_vec(idxS+3),scales_vec(idxS),scales_vec(idxS-3)];

% save results of scale sweep
result.ScaleSweep.scale = scale;
result.ScaleSweep.scales_vec = scales_vec;
result.ScaleSweep.cost = cost_log;
result.ScaleSweep.idxP = idxP;

% pick subset of particles
subParticles = cell(1,N);
gtparam = cell(1,N);
idx=1;
sampling = datasample(1:length(particles),N,'Replace',false);
for i=sampling
    subParticles{1,idx}.points = particles{1,i}.coords(:,1:3);
%             idxZ = find(subParticles{1,idx}.points(:,3) > 1 | subParticles{1,idx}.points(:,3) < -1);
%             subParticles{1,idx}.points(idxZ,:) = [];
    subParticles{1,idx}.sigma = [particles{1,i}.coords(:,5) particles{1,i}.coords(:,10)].^2;
%             subParticles{1,idx}.sigma(idxZ,:) = [];
    gtparam(idx) = {particles{1,i}.param};
    idx=idx+1;
end

 result.sampling = sampling;
 result.gtparam = gtparam;

% filter out localisations with precision above 1.5*mean value (optional)
    % other criteria for filtering localisations can also be applied
sig = [];
for ii=1:N
    sig = [sig;subParticles{ii}.sigma];
end
meansig = mean(sig);
for ii=1:N
    [idxS,~] = find(subParticles{ii}.sigma > tolerance*meansig);
    idxS = unique(idxS);
    subParticles{ii}.points(idxS,:) = [];
    subParticles{ii}.sigma(idxS,:) = [];
end

% core reconstruction functions
% 1. all to all registration
disp('all2all registration started!');
[RR, I,cost] = all2all3D(subParticles, scale,initAng, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST);
% [RR, I,cost] = all2all3D(subParticles, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST);
        
% plot cost matrix
f1 = figure('visible',vis,'units','normalized','outerposition',[0 0 0.5 1]);
imagesc(cost)
colorbar;
map = [1,1,1;cool(1000)];
colormap(map)
grid on
set(gca,'fontsize',20)
title('cost function value matrix')
saveas(f1,[outputdir,'/cost_func_mat.png'])

result.all2all.relative_params = RR;
result.all2all.cost = cost;

% 2. Lie-algebraic averaging and outlier removal
disp('Lie-algebraic averaging started!');
[Mest,~] = MeanSE3Graph(RR, I);
[RM_new, I_new] = consistencyCheck(Mest, RR, I, N);
disp('2nd Lie-algebraic averaging started!');
[M_new,~] = MeanSE3Graph(RM_new,I_new);

[initAlignedParticles, intermediate] = makeTemplate(M_new, subParticles, N);

% show intermediate result after Lie-averaging
f2=figure('visible',vis,'units','normalized','outerposition',[ 0 0 0.5 1])
tmp = intermediate;
wd = 3*std(tmp);
scatter3(tmp(:,1),tmp(:,2),tmp(:,3),'.','markeredgecolor','red')
xlim([-wd(1) wd(1)])
ylim([-wd(2) wd(2)])
zlim([-wd(3) wd(3)])
axis square
set(gcf,'units','normalized','outerposition',[0 0 0.5 1],...
    'InvertHardCopy','off','color',[0 0 0],'visible',vis)
set(gca,'Fontsize',28,...
    'GridColor',[1 1 1],...
    'Ycolor',[1 1 1],...
    'Xcolor',[1 1 1],...
    'Zcolor',[1 1 1],...
    'color',[0 0 0])       
xlabel('x [nm]','color',[1 1 1])
ylabel('y [nm]','color',[1 1 1])
zlabel('z [nm]','color',[1 1 1])
title('intermediate superparticle','color', [1 1 1])
saveas(f2,[outputdir,'/intermediate.fig'])

% optinal: save rotating gif of the 3D figure
filename = [outputdir,'/intermediate.gif'];
for ii=1:72
    camorbit(5,0)
    frame = getframe(f2);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if ii==1
    imwrite(imind,cm,filename,'gif','loopcount',inf,'delay',delay);
    else
    imwrite(imind,cm,filename,'gif','WriteMode','append','delay',delay);
    end
end

result.Lie.intermediate = intermediate;
result.Lie.intermediate_params = M_new;

% network approach to coerce registrations into common reference frame
filename='.';
newP = OptimalSE3Graph(cost,subParticles,RR,filename);
Altintermediate = [];
for ii=1:N
    Altintermediate =[Altintermediate;newP{ii}.points];
end

% show result of network rotation
f3=figure('visible',vis,'units','normalized','outerposition',[ 0 0 0.5 1]);
tmp = Altintermediate;
wd = 3*std(tmp);
scatter3(tmp(:,1),tmp(:,2),tmp(:,3),'.','markeredgecolor','red')
xlim([-wd(1) wd(1)])
ylim([-wd(2) wd(2)])
zlim([-wd(3) wd(3)])
axis square
set(gcf,'units','normalized','outerposition',[0 0 0.5 1],...
    'InvertHardCopy','off','color',[0 0 0],'visible',vis)
set(gca,'Fontsize',28,...
    'GridColor',[1 1 1],...
    'Ycolor',[1 1 1],...
    'Xcolor',[1 1 1],...
    'Zcolor',[1 1 1],...
    'color',[0 0 0])       
xlabel('x [nm]','color',[1 1 1])
ylabel('y [nm]','color',[1 1 1])
zlabel('z [nm]','color',[1 1 1])
saveas(f3,[outputdir,'/network_intermediate.fig'])

% optinal: save rotating gif of the 3D figure
filename = [outputdir,'/network_intermediate.gif'];
for ii=1:72
    camorbit(5,0)
    frame = getframe(f3);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if ii==1
    imwrite(imind,cm,filename,'gif','loopcount',inf,'delay',delay);
    else
    imwrite(imind,cm,filename,'gif','WriteMode','append','delay',delay);
    end
end

result.OptimalSE3 = newP;

% 3. bootstrapping of the intermediate superparticle by one-2-all alignment
[superParticle, ~] = one2all3D(initAlignedParticles, iter, M1, '.', intermediate,...
    USE_SYMMETRY,scale,initAng, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST);
% [superParticle, ~] = one2all3D(initAlignedParticles, iter, M1, '.', intermediate,...
%     USE_SYMMETRY, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST);
[finalParticles, transform] = get_final_transform_params(superParticle{end}, subParticles);
        
% show result of network rotation
f4=figure('visible',vis,'units','normalized','outerposition',[ 0 0 0.5 1]);
tmp = superParticle{end};
wd = 3*std(tmp);
scatter3(tmp(:,1),tmp(:,2),tmp(:,3),'.','markeredgecolor','red')
xlim([-wd(1) wd(1)])
ylim([-wd(2) wd(2)])
zlim([-wd(3) wd(3)])
axis square
set(gcf,'units','normalized','outerposition',[0 0 0.5 1],...
    'InvertHardCopy','off','color',[0 0 0],'visible',vis)
set(gca,'Fontsize',28,...
    'GridColor',[1 1 1],...
    'Ycolor',[1 1 1],...
    'Xcolor',[1 1 1],...
    'Zcolor',[1 1 1],...
    'color',[0 0 0])       
xlabel('x [nm]','color',[1 1 1])
ylabel('y [nm]','color',[1 1 1])
zlabel('z [nm]','color',[1 1 1])
saveas(f4,[outputdir,'/superparticle.fig'])

% optinal: save rotating gif of the 3D figure
filename = [outputdir,'/superparticle.gif'];
for ii=1:72
    camorbit(5,0)
    frame = getframe(f4);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if ii==1
    imwrite(imind,cm,filename,'gif','loopcount',inf,'delay',delay);
    else
    imwrite(imind,cm,filename,'gif','WriteMode','append','delay',delay);
    end
end
        
result.final.finalparticles = finalParticles;
result.final.transform = transform;

% save result
save([outputdir,'/result.mat'],'result')



