% compute the distance between two particles of size 32x3

function D = particleDist(par1, par2)

    Dist = zeros(1,8);
    chunk1 = par2(1:8,:);      % upper ring 1 set
    chunk2 = par2(9:16,:);     % upper ring, shifted by 10 deg to make dubble blob per set
    chunk3 = par2(17:24,:);    % lower ring
    chunk4 = par2(25:32,:);    % lower ring, shifted by 10 deg to make dubble blob per set

    for i=1:8
        tmpPar2 = [circshift(chunk1, i-1);
                            circshift(chunk2, i-1);
                            circshift(chunk3, i-1);
                            circshift(chunk4, i-1)];
        Dist(i) = sum(sqrt(sum((par1 - tmpPar2).^2, 2)));
    end

    % % suggestion from bernd for uppper lower flipping
    % for i=9:16
    %     tmpPar2 = [circshift(chunk3, i-1);
    %                         circshift(chunk4, i-1);
    %                         circshift(chunk1, i-1);
    %                         circshift(chunk2, i-1)];
    %     Dist(i) = sum(sqrt(sum((par1 - tmpPar2).^2, 2)));
    % end

    D = min(Dist);

end