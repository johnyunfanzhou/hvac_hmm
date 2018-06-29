function [currentState, logP] = hvacviterbi(data, tr, e, Sn, Hn, Wn)
%% Modified hmmviterbi for the HVAC model.
%   Transition matrix has size (Sn * Hn * Wn * 2, 2).
%   Emission matrix has size (Sn * Hn * Wn * 2, Mn).
%% HMMVITERBI calculates the most probable state path for a data(:, 1)uence.
%   STATES = HMMVITERBI(data(:, 1),TRANSITIONS,EMISSIONS) given a data(:, 1)uence, data(:, 1),
%   calculates the most likely path through the Hidden Markov Model
%   specified by transition probability matrix, TRANSITIONS, and emission
%   probability matrix, EMISSIONS. TRANSITIONS(I,J) is the probability of
%   transition from state I to state J. EMISSIONS(K,L) is the probability
%   that symbol L is emitted from state K.
%
%   HMMVITERBI(...,'SYMBOLS',SYMBOLS) allows you to specify the symbols
%   that are emitted. SYMBOLS can be a numeric array or a string/cell array
%   of the names of the symbols.  The default symbols are integers 1
%   through N, where N is the number of possible emissions.
%
%   HMMVITERBI(...,'STATENAMES',STATENAMES) allows you to specify the names
%   of the states. STATENAMES can be a numeric array or a cell array of the
%   names of the states. The default statenames are 1 through M, where M is
%   the number of states.
%
%   This function always starts the model in state 1 and then makes a
%   transition to the first step using the probabilities in the first row
%   of the transition matrix. So in the example given below, the first
%   element of the output states will be 1 with probability 0.95 and 2 with
%   probability .05.
%
%   Examples:
%
% 		tr = [0.95,0.05;
%             0.10,0.90];
%           
% 		e = [1/6,  1/6,  1/6,  1/6,  1/6,  1/6;
%            1/10, 1/10, 1/10, 1/10, 1/10, 1/2;];
%
%       [data(:, 1), states] = hmmgenerate(100,tr,e); estimatedStates =
%       hmmviterbi(data(:, 1),tr,e);
%
%       [data(:, 1), states] =
%       hmmgenerate(100,tr,e,'Statenames',{'fair';'loaded'});
%       estimatesStates =
%       hmmviterbi(data(:, 1),tr,e,'Statenames',{'fair';'loaded'});
%
%   See also HMMGENERATE, HMMDECODE, HMMESTIMATE, HMMTRAIN.

%   Reference: Biological data(:, 1)uence Analysis, Durbin, Eddy, Krogh, and
%   Mitchison, Cambridge University Press, 1998.

%   Copyright 1993-2011 The MathWorks, Inc.

%% tr is Sn * Hn * Wn * 2 by 2

numStates = size(tr,1);
if numStates ~= Sn * Hn * Wn * 2
    error(message('stats:hvacviterbi:BadTransitions'));
end
checkTr = size(tr,2);
if checkTr ~= 2
    error(message('stats:hvacviterbi:BadTransitions'));
end

%% number of rows of e must be same as number of states

checkE = size(e,1);
if checkE ~= numStates
    error(message('stats:hvacviterbi:InputSizeMismatch'));
end

numEmissions = size(e,2);

%% work in log space to avoid numerical issues
L = length(data(:, 1));
seq = data(:, 1) + 1;
if any(seq(:)<1) || any(seq(:)~=round(seq(:))) || any(seq(:)>numEmissions)
     error(message('stats:hmmviterbi:BadSequence', numEmissions));
end
currentState = zeros(1,L);
if L == 0
    return
end
logTR = log(tr);
logE = log(e);

%% allocate space
pTR = zeros(2,L);
% assumption is that model is in state 1 at step 0
v = -Inf(2,1);
v(1,1) = 0;
vOld = v;

%% loop through the model
for count = 1:L
    % check if data is continuous or not
    datacontinuous = true;
    if count == 1
        datacontinuous = false;
    elseif mod(data(count, 3) - data(count - 1, 3), 48) ~= 1
        datacontinuous = false;
    elseif data(count, 3) ~= 0
        if data(count, 2) ~= data(count - 1, 2)
            datacontinuous = false;
        elseif data(count, 4) ~= data(count - 1, 4)
            datacontinuous = false;
        end
    end
    if datacontinuous
        s = data(count - 1, 2);
        h = mod(data(count - 1, 3), Hn);
        w = data(count - 1, 4);
    else
        s = data(count, 2);
        h = mod(data(count, 3) - 1, Hn);
        w = data(count, 4);
    end
    for state = 1:2
        % for each state we calculate
        % v(state) = e(state,seq(count))* max_k(vOld(:)*tr(k,state));
        bestVal = -inf;
        bestPTR = 0;
        % use a loop to avoid lots of calls to max
        for inner = 1:2
            index = inner + 2 * (h + Hn * (w + Wn * s));
            val = vOld(inner) + logTR(index,state);
            if val > bestVal
                bestVal = val;
                bestPTR = inner;
            end
        end
        % save the best transition information for later backtracking
        pTR(state,count) = bestPTR;
        % update v
        v(state) = logE(state,seq(count)) + bestVal;
    end
    vOld = v;
end

% decide which of the final states is post probable
[logP, finalState] = max(v);

% Now back trace through the model
currentState(L) = finalState;
for count = L-1:-1:1
    currentState(count) = pTR(currentState(count+1),count+1);
    if currentState(count) == 0
        error(message('stats:hmmviterbi:ZeroTransitionProbability', currentState( count + 1 )));
    end
end
currentState = currentState(:) - 1;