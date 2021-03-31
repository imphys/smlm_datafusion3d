function MT = transposeSE3(M)

    MT = zeros(4,4);
    R = M(1:3,1:3); % rotation
    T = M(1:3,4);   % translation
    
    MT(1:3,1:3) = transpose(R);
    MT(1:3,4) = -transpose(R)*T;
    MT(4,4) = 1;

end