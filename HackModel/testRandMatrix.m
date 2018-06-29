% testing program
% create random transition and emission matrices and generate data, which
% will be used for training and hopefully recover the random matrices.
function [accuracyT, accuracyE] = testRandMatrix(Sn, Wn, Hn, datalength, maxIteration)

    if nargin < 5
        maxIteration = 10;
        if nargin < 4
            datalength = 17520;
        end
    end
    
    testT = rand(576, 2);
    testE = rand(576, 2);
    testT = mk_stochastic(testT);
    testE = mk_stochastic(testE);

    %% create data

    data = zeros(datalength, 4);
    datasize = size(data, 1);
    for i = 1 : datasize
        d = floor(i / Hn);
        s = 2 - (d > 59) - (d > 151) + (d > 243) + (d > 334);
        h = mod(i - 1, Hn);
        w = (mod(d, 7) > 5);
        data(i, 2) = s;
        data(i, 3) = h;
        data(i, 4) = w;
        if i == 1
            data(i, 1) = floor(2 * rand);
            continue;
        end
        index = data(i - 1, 1) + 2 * (h + Hn * (w + Wn * s)) + 1;
        data(i, 1) = (rand > testT(index, 1));
    end

    %% learn data with HackModel.m

    [A, B] = HackModel(data, Sn, Hn, Wn, maxIteration, true);

    %% compute accuracy
    accuracyT = 1 - sum(sum((A - testT) .^ 2)) / 1152;
    accuracyE = 1 - sum(sum((B - testE) .^ 2)) / 1152;
end
