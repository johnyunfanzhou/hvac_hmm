function [new_data, forward_prob] = hvacpredict(A, B, data, Sn, Hn, Wn, narray, supressOutput, forward_prob, abortCheck)
% Inputs:
%   A: transition matrix, 576x2
%   B: Emission matrix, 576x2
%   data: entire data read from CSV, matrix of size (# sample)x4, each row
%         is (M, S, H, W).
%   Sn: # of possible values for season (3)
%   Hn: # of possible values for hour (48)
%   Wn: # of possible values for week (2)
%   narray: a list of indexes. Data at these indexes are used as test data,
%           and prediction will be performed on these data.
%   supressOutput: default to false
%   forward_prob: probability matrix of size (# sample)x2. Entry at (k, 0)
%                 represents the probability that M at kth data is 0, and 
%                 entry at (k, 1) represents the probability that M at the 
%                 kth data is 1 (i.e., kth row is [P(O_k=0), P(O_k=1)]).
%                 If the k's data is observed (in the training set), row k
%                 of this matrix should be set as [0.0, 1.0] or [1.0, 0.0].
%                 Default fills all training data rows as [0.0, 1.0] or 
%                 [1.0, 0.0] according to data, and leaves testing data
%                 rows as [0.0, 0.0] to be updated later during prediction.
%   abortCheck: boolean if all input should be checked for correctness.
%               Default at false;
% Outputs:
%   new_data: entire data matrix; train data entries are read from CSV,
%             test data S, H, W entries are read from CSV, test data M
%             entries are predicted.
%   forward_prob: probability matrix of size (# sample)x2 taken from input,
%                 with all testing data rows filled according to the 
%                 observation probability.

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
        if nsize < 1
            error('No data to predict.');
        end
        if nsize > 17520
            warning('Size of prediction is larger than 17520 and may cause insufficient memory.');
        end
        if ~isequal(size(forward_prob), [datasize, 2])
            error('Invalid probability vector size. Previous forward probabily has to be size datasizex2.');
        end
        hvaccheckmatrix(A, B, Sn, Hn, Wn);
        hvaccheckdata(data, Sn, Hn, Wn);
        if ~supressOutput
            disp('Autogenerating existing forward probabilities.');
        end
        for i = 1 : datasize
            if ~ismember(i, narray)
                forward_prob(i, :) = [data(i, 1) == 0, data(i, 1) == 1];
            end
        end
    end
    
    n = narray(1);
    
    s = data(n, 2);
    h = data(n, 3);
    w = data(n, 4);
    
    new_data = data;

    % map (0 : 1, S, H, W) to one pair of numbers
    index = 2 * (h + Hn * (w + Wn * s)) + 1 : 2 * (h + Hn * (w + Wn * s)) + 2;
    
    clear abortCheck datacontinuous data prev_forward_prob;
    
    if n == 1
        warning('Predicting first entry. Previous forward probability is assumed [0.5, 0.5].');
        % New observation probability for O_t+1 = 
        % previous observation probability for O_t * P(S_t|O_t) *
        % (PS_t+1|S_t) * P(O_t+1|S_t+1)
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
