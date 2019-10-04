% [result] = transform_by_rigid3d(pointset, param)
% perform a 3D rigid transform on a pointset and
% return the transformed pointset
% Note that here 3D rigid transform is parametrized by 7 numbers
% [quaternion(1 by 4) translation(1 by 3)]
%
% See also: quaternion2rotation, transform_by_rigid2d,
% transform_by_affine3d

function [result] = rotate_by_pifourth3d(pointset)
%%=====================================================================
%% $RCSfile: transform_by_rigid3d.m,v $
%% $Author: bing.jian $
%% $Date: 2008-11-30 18:09:59 -0500 (Sun, 30 Nov 2008) $
%% $Revision: 116 $
%%=====================================================================
angle = floor(8*rand)*pi/4;
angdeg = rad2deg(angle);
r = [cosd(angdeg) -sind(angdeg) 0; sind(angdeg) cosd(angdeg) 0; 0 0 1];
result = pointset*r';

