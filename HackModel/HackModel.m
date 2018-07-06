function [A, B, state, itr] = HackModel(data, Sn, Hn, Wn, maxIteration, supressOutput)
    
    % supress output

    if nargin < 6
        supressOutput = false;
        if nargin < 5
            maxIteration = 10;
        end
    end
    
    datasize = size(data, 1);

    state = [-1; data(1 : size(data) - 1, 1)];
    
    hvaccheckdata(data, Sn, Hn, Wn);

    % possible number of states (N) and observations (M)
    N = Sn * Wn * Hn * 2;

    % state transition matrix (A) and observation probability matrix (B)
    A = ones (N, 2);
    B = ones (N, 2);
    
    itr = maxIteration;
    % loop
    for iteration = 1 : maxIteration
        % set A and B according to conditional probability
        for i = 1 : datasize
            s = data(i, 2);
            h = data(i, 3);
            w = data(i, 4);
            o = state(i);
            index = o + 2 * (h + Hn * (w + Wn * s)) + 1;
            if (i ~= datasize)
                o_next = state(i + 1) + 1;
                A(index, o_next) = A(index, o_next) + 1;
            end
            m = data(i, 1) + 1;
            B(index, m) = B(index, m) + 1;
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

