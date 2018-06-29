function [new_data, forward_prob] = hvacpredict(prev_forward_prob, A, B, data, Sn, Hn, Wn, n, supressOutput, abortCheck)
    
    if nargin < 10
        abortCheck = false;
        if nargin < 9
            supressOutput = false;
            if nargin < 8
                n = 1;
            end
        end
    end
    
    datasize = size(data, 1);
    
    % check if inputs are valid
    if ~abortCheck
        if datasize - n > 17519
            data = data(1 : n + 17519, :);
        end
        if ~isequal(size(prev_forward_prob), [2, 1])
            error('Invalid probability vector size. Previous forward probabily has to be size 2x1.');
        end
        hvaccheckmatrix(A, B, Sn, Hn, Wn);
        hvaccheckdata(data, Sn, Hn, Wn);
    end
    
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
    
    clear abortCheck datacontinuous data;
    
    forward_prob = (((B(index, :) ./ sum(B(index, :))) * prev_forward_prob)' * A(index, :) * B(index, :))';
    new_data(n, 1) = argmax(forward_prob) - 1;
    
    clear index prev_forward_prob;
    
    if n ~= datasize
        if ~supressOutput
            fprintf('Observation #%d generated.\n', n);
        end
        [new_data, forward_prob] = hvacpredict(forward_prob, A, B, new_data, Sn, Hn, Wn, n + 1, false, true);
    end
end
