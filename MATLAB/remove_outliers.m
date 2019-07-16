function [RR, I] = remove_outliers(RR, I, Mest, outlier_threshold)

if size(RR,3) <= 1; return; end

n_particles = size(Mest, 3);

kk = 1;
relR = zeros(3,3,1);
for i=1:n_particles-1
    for j=i+1:n_particles

        relR(:,:,kk) = Mest(1:3,1:3,j)'*Mest(1:3,1:3,i);
        kk = kk+1;

    end
end

d = zeros(size(RR,3),1);

for i=1:size(RR,3)
   d(i) =  distSE3(RR(:,:,i),relR(:,:,i));
end

error_idx = abs(d) > outlier_threshold;

RR(:,:,error_idx) = [];
I(:,error_idx) = [];

end