function MN = multiplySE3(M,N)

    MN = zeros(4,4);
    
    RM = M(1:3,1:3); % rotation
    TM = M(1:3,4);   % translation
    
    RN = N(1:3,1:3); % rotation
    TN = N(1:3,4);   % translation    
    
    MN(1:3,1:3) = RM*RN;
    MN(1:3,4) = RM*TN+TM;
    MN(4,4) = 1;

end