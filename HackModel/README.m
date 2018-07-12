% HVAC_HMM_HackModel.m Explanation
% 
% Run the HVAC_HMM_HackModel.m to build the hmm model.
% 
% The algorithm of the HackModel is as following:
% 
% 1. Shift all observations one step ahead as the initial sequence of true
% occupancy states.
% 
% 2. Construct the transition and emission matrices using Naive Bayes with
% Laplace Smoothing
% 
%                               # occurance of "next_state|curr_state" + 1
%   A(curr_state, next_state) = ------------------------------------------
%                                    # occurance of "curr_state" + 2
% 
%                           # occurance of "observation|state" + 1
%   B(observation, state) = --------------------------------------
%                                 # occurance of "state" + 2
% 
% 
%   Note: the transition matrix is 3 * 48 * 2 individual 2 * 2 matrices.
%   The transition matrix depends on the value of S, H, and W.
% 
% 3. Using Viterbi algorithm (hvacviterbi.m) to update the most probable
% sequence of true occupancy states given the sequence of observations, the
% transition matrix and the emission matrix.
% 
%   Note: The transition matrix used to calculate the likelihood of a state
%   depends on the S, H, and W of the previous timestep. If discontinuous
%   data is detected, an approximation is used in determining them:
%       S, H, and W of the current timestep is readed and H is substracted
%       by 1.
%   Since season and weekday/weekend does not change as often as hour, this
%   approximation is reasonable.
%   
%   A data discontinuity is detected if:
%       i.   it is the first entry in the data and there is no previous
%            timestep
%       ii.  h does not increase by 1
%       iii. h is not 0 (it is not the starting of a day) but season or
%            weekday/weekend has changed, meaning we probably skipped
%            exactly one day
% 
% 4. Step 2 and 3 are repeated using the most probable sequence of true
% occupancy states generated from the last iteration.
