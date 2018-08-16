function [A, B, state, itr] = HackModel(data, Sn, Hn, Wn, maxIteration, supressOutput)
% Inputs:
%   data: entire data read from CSV, matrix of size (# sample)x4, each row
%         is (M, S, H, W).
%   Sn: # of possible values for season (3)
%   Hn: # of possible values for hour (48)
%   Wn: # of possible values for week (2)
%   maxIteration: maximum number of iterations viterbi EM can perform.
%                 Default to 10.
%   supressOutput: default to false
% Outputs:
%   A: trained transition matrix
%   B: trained emission matrix
%   state: trained sequence of hidden states
%   itr: number of iterations to reach absolute convergence

    if nargin < 6
        supressOutput = false;
        if nargin < 5
            maxIteration = 10;
        end
    end
    
    datasize = size(data, 1);

    state = floor(rand(datasize, 1) * 2);
    
    hvaccheckdata(data, Sn, Hn, Wn);

    % possible number of states (N) and observations (M)
    N = Sn * Wn * Hn * 2;

    % state transition matrix (A) and observation probability matrix (B)
    % use ones to achieve laplace smoothing
    A = ones (N, 2);
    B = ones (N, 2);
    
    itr = maxIteration + 1;
    % loop
    for iteration = 1 : maxIteration
        % set A and B according to conditional probability
        for i = 1 : datasize
            s = data(i, 2);
            h = data(i, 3);
            w = data(i, 4);
            o = state(i);
            if i ~= 1
                o_prev = state(i - 1);
                index = o_prev + 2 * (h + Hn * (w + Wn * s)) + 1;
                A(index, o + 1) = A(index, o + 1) + 1;
            end
            index = o + 2 * (h + Hn * (w + Wn * s)) + 1;
            m = data(i, 1);
            B(index, m + 1) = B(index, m + 1) + 1;
        end

        % normalized matrices
        A = mk_stochastic(A);
        B = mk_stochastic(B);

        % viterbi to find new states
        oldstate = state;
        state = hvacviterbi(data, A, B, Sn, Hn, Wn);
        state_changed = sum(abs(state - oldstate));
        if ~supressOutput
            fprintf('Iteration %d: %d state(s) changed\n', iteration, state_changed);
        end
        if state_changed == 0
            itr = iteration;
            break;
        end
    end
end

