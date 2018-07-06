function [new_data, forward_prob] = hvacpredict(A, B, data, Sn, Hn, Wn, narray, supressOutput, forward_prob, abortCheck)
    
    datasize = size(data, 1);
    nsize = size(narray, 2);

    if nargin < 10
        abortCheck = false;
        if nargin < 9
            forward_prob = zeros(datasize, 2);
            if nargin < 8
                supressOutput = false;
            end
        end
    end
    
    % check if inputs are valid (only once)
    if ~abortCheck
        if nsize > 17520
            warning("Size of prediction is larger than 17520 and may cause insufficient memory.");
        end
        if ~isequal(size(forward_prob), [datasize, 2])
            error('Invalid probability vector size. Previous forward probabily has to be size datasizex2.');
        end
        hvaccheckmatrix(A, B, Sn, Hn, Wn);
        hvaccheckdata(data, Sn, Hn, Wn);
        disp('Autogenerating existing forward probabilities.');
        for i = 1 : datasize
            if ~ismember(i, narray)
                forward_prob(i, :) = [data(i, 1) == 0, data(i, 1) == 1];
            end
        end
    end
    
    n = narray(1);
    
    % check if data is continuous or not
    datacontinuous = true;
    if n == 1
        datacontinuous = false;
    elseif mod(data(n, 3) - data(n - 1, 3), 48) ~= 1
        datacontinuous = false;
    elseif data(n, 3) ~= 0
        if data(n, 2) ~= data(n - 1, 2)
            datacontinuous = false;
        elseif data(n, 4) ~= data(n - 1, 4)
            datacontinuous = false;
        end
    end
    
    if datacontinuous
        s = data(n - 1, 2);
        h = data(n - 1, 3);
        w = data(n - 1, 4);
    else
        s = data(n, 2);
        h = data(n, 3) - 1;
        w = data(n, 4);
    end
    
    new_data = data;

    index = 2 * (h + Hn * (w + Wn * s)) + 1 : 2 * (h + Hn * (w + Wn * s)) + 2;
    
    clear abortCheck datacontinuous data prev_forward_prob;
    
    if n == 1
        warning('Predicting first entry. Previous forward probability is assumed [0.5, 0.5].');
        forward_prob(n, :) = ([0.5, 0.5] * (B(index, :) ./ sum(B(index, :)))') * A(index, :) * B(index, :);
    else
        forward_prob(n, :) = (forward_prob(n - 1, :) * (B(index, :) ./ sum(B(index, :)))') * A(index, :) * B(index, :);
    end
    
    new_data(n, 1) = argmax(forward_prob(n, :)) - 1;
    
    clear index;
    
    if ~supressOutput
        fprintf('Observation #%d generated.\n', n);
    end
    
    if nsize ~= 1
        [new_data, forward_prob] = hvacpredict(A, B, new_data, Sn, Hn, Wn, narray(2:nsize), supressOutput, forward_prob, true);
    end
end
