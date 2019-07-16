%VISUALCLOUD Displays multiple isosurfaces of the binned density of the pointcloud.
%On top of that is displays the model.
% 
% SYNOPSIS:
%   visualizeCloud(pointcloud, bins, model, output)
% 
% INPUT PARAMETERS:
%   pointcloud
%      [x y z; ...]
%   bins
%      number of bins in all directions
%   model            
%      either [] or a model of [x y z] points
%   output              
%      either false, 'gif', 'movie'
% 
% DEFAULTS:
%   none
% 
% NOTES:
%  none
% 
% (C) Copyright 2015               Diederik Feilzer
%     All rights reserved          Delft University of Technology
% 
% Diederik Feilzer, juli 2015

function [ ] = visualizeCloud3DSurface(pointcloud, bins, model, output)

h=figure('pos',[100 100 1000 1000]);
clf;
n = bins;
X = pointcloud;

diameter = max(std(pointcloud,1))*5; %auto from pointcloud
ROIradius = 0.5*diameter;

%model = model - repmat(mean(model,1),[size(model,1) 1]);

X = X(find(X(:,1) < ROIradius & X(:,1) > (-ROIradius)),:);
X = X(find(X(:,2) < ROIradius & X(:,2) > (-ROIradius)),:);
X = X(find(X(:,3) < ROIradius & X(:,3) > (-ROIradius)),:);

xi = linspace(-ROIradius,ROIradius,n);
yi = linspace(-ROIradius,ROIradius,n);
zi = linspace(-ROIradius,ROIradius,n);

xr = interp1(xi,1:numel(xi),X(:,1),'nearest');
yr = interp1(yi,1:numel(yi),X(:,2),'nearest');
zr = interp1(zi,1:numel(zi),X(:,3),'nearest');

Z = accumarray([xr yr zr],1, [n n n]);

data = smooth3(Z,'gaussian',3);

data = permute(data,[2 1 3])./max(data(:));

quarants = [0.05 0.1 0.2 0.4:0.1:0.7];

%quarants = [0.2 0.4:0.1:0.7];

%quarants = [0.5:0.1:0.7];

%quarants = [0.4:0.1:0.7];

for quarant = 1:size(quarants,2)

patch(isocaps(data,quarants(1,quarant)),'FaceColor','interp','EdgeColor','none','FaceAlpha',(1/(size(quarants,2)^2))*quarant*quarant);
p1 = patch(isosurface(data,quarants(1,quarant)),'FaceColor',[1 0 0],'EdgeColor','none','FaceAlpha',(1/(size(quarants,2)^2))*quarant*quarant);

isonormals(data,p1);

end

if size(model,2) == 3 && size(model,1) > 0 

    tmpmodel(:,1)=n*(model(:,1)-mean(model(:,1))+ROIradius)/diameter;
    tmpmodel(:,2)=n*(model(:,2)-mean(model(:,2))+ROIradius)/diameter;
    tmpmodel(:,3)=n*(model(:,3)-mean(model(:,3))+ROIradius)/diameter;

    for i = 1:size(tmpmodel,1)

        for j = 1:size(tmpmodel,1)
            if i ~= j
                hold on
                plot3(tmpmodel([i j],1),tmpmodel([i j],2),tmpmodel([i j],3),'-b','LineWidth',1);
            end
        end
    end
end

view(3); 
axis vis3d;
axis equal;
%camlight headlight;
camlight left
colormap jet;
lighting gouraud;
box on;

set(gca,'XTickLabel',[])
set(gca,'XTick',[])
set(gca,'YTickLabel',[])
set(gca,'YTick',[])
set(gca,'ZTickLabel',[])
set(gca,'ZTick',[])
axis square
set(gca,'color','none')
if strcmp(output,'gif')

    filename = 'animation.gif';

    for i=1:4:360
        view(i+30, sin(i*2*pi/360)*70+20);
        drawnow
        frame = getframe(1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if i == 1;
          imwrite(imind,cm,filename,'gif','Loopcount',inf);
        else
          imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',1/100);
        end
    end

end

if strcmp(output,'movie')

    filename = 'movie.avi';

    aviobj = avifile(filename,'fps',20,'compression','none');
    for i=1:2:360
        view(i+30, sin(i*2*pi/360)*70+20);
        drawnow
        frame = getframe(1);
        aviobj = addframe(aviobj,frame);
    end

    aviobj = close(aviobj);

end

end