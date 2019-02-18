function d = distSE3(X,Y)

%DISTXY Custom Distance metric for the JHU kinematics data
% 1-3    (3) : tooltip xyz                    
% 4-12   (9) : tooltip R    
% 13-15  (3) : tooltip trans vel x', y', z'   
% 16-18  (3) : tooltip rot_vel                
% 19     (1) : gripper angle   
% We use the scale dependent left-invariant metric from 
% "Distance Metrics on the Rigid Body Rotations with Applications 
% to Mechanism Design "

if nargin <3
    w = [1, 2]; %this works under appropriate scaling of positions
else 
    w = varargin{1};
end
    
% euclidiean distance
% d_trans = norm(X(1:3,4)- Y(1:3,4),2); 

% rotation matrix similarity
R1 = X(1:3,1:3);
R2 = Y(1:3,1:3);
% d_rot = 0.5*trace(logm(R1'*R2));
% d_rot = norm(logm(R1'*R2),'fro');
d_rot = trace(logm(R1'*R2)'*logm(R1'*R2));
%quaternion Distance
% qx = dcm2quat(R1);
% qy = dcm2quat(R2);
% 
% d_quat = 1 - abs(qx.*qy); %[0,1] measure of similarity

% d = w(1)*d_trans + w(2)*d_rot;
d = d_rot;
end