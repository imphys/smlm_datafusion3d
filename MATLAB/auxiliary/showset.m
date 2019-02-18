function showset(data,cmap,t)
% Displays 
% INPUT:
% data - m-by-(1,2,or 3) array of data points.  
% cmap - m-by-3 array representing rgb values associated with each data
%        point
% t    - m-by-1 array of x-values (optional)
%
% Written by Kye M Taylor, 2005.

[~,n]=size(data);

msz = 3; % marker size

hold on
if n == 3
%   for i = 1:size(cmap,1)
% %     plot3(data(i,1),data(i,2),data(i,3),'.','MarkerEdgeColor',cmap(i,:),'markersize',msz)
%     scatter3(data(i,1),data(i,2),data(i,3),'.','MarkerEdgeColor',cmap(i,:))
%   end
  scatter3(data(:,1),data(:,2),data(:,3),'.','MarkerEdgeColor',cmap(:))
%   scatter3(data(:,1),data(:,2),data(:,3),'.',cmap(:,1),cmap(:,2),cmap(:,3))
  view(3)
elseif n==2
  for i = 1:size(cmap,1)
      plot(data(i,1),data(i,2),'.','MarkerEdgeColor',cmap(i,:),'markersize',msz)
  end
  view(2)
else
  if nargin<3 % if no dependendent variable given for plotting a column vector, plot over [0,1).
    t = 1:size(data,1);
    t = (t-1)/size(data,1);
  end
  for i = 1:size(cmap,1)
      plot(t(i),data(i),'.','MarkerEdgeColor',cmap(i,:),'markersize',msz)
  end
  view(2)
end
set(gca,'Color','k')
hold off
        
    