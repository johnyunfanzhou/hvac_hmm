function [accuracy, predictions, fPred, fProb, A, B, state] = testPrediction(data, Sn, Hn, Wn, testPercentage, maxIteration, supressOutput)
% randomly choose some entries in the entire data as test data, and predict
% the observations of these data. This random process is performed for 30
% trials. Mean accuracy of the 30 trials are calculated. A 
% Inputs:
%   data: entire data read from CSV, matrix of size (# sample)x4, each row
%         is (M, S, H, W).
%   Sn: # of possible values for season (3)
%   Hn: # of possible values for hour (48)
%   Wn: # of possible values for week (2)
%   testPercentage: percentage of data to be used as test data. Default to
%                   0.25.
%   maxIteration: maximum number of iterations viterbi EM can perform.
%                 Default to 10.
%   supressOuput: default to false
% Outputs:
%   accuracy: percentage of data predicted correctly, between 0.0 and 1.0.
%   predictions: average prediction of every entry in the data
%   fPred: figure of prediction results
%   fProb: figure of observation prediction probabilities
%   A: trained transition matrix
%   B: trained emission matrix
%   state: trained sequence of hidden states

    if nargin < 7
        supressOutput = true;
        if nargin < 6
            maxIteration = 10;
            if nargin < 5
                testPercentage = 0.25;
            end
        end
    end

    hvaccheckdata(data, Sn, Hn, Wn);
    
    datasize = size(data, 1);
    testsize = min([datasize - 1, 17520, round(testPercentage * datasize)]);
    
    alldata = 1 : datasize;
    allaccuracy = zeros(30, 1);
    avgpredictions = zeros(datasize, 1);
    countpredictions = zeros(datasize, 1);
    avgforward_prob = zeros(datasize, 2);
    countforward_prob = zeros(datasize, 1);
    for trial = 1 : 30
        testdata = sort(randperm(datasize - 1, testsize) + 1);
        traindata = alldata(~ismember(alldata, testdata));
        [A, B, state] = HackModel(data(traindata, :), Sn, Hn, Wn, maxIteration, true);
        [new_data, forward_prob] = hvacpredict(A, B, data, Sn, Hn, Wn, testdata, supressOutput);
        predictions = new_data(:, 1);
        allaccuracy(trial) = 1 - sum(abs(predictions(testdata) - data(testdata, 1)))/testsize;
        avgpredictions(testdata) = avgpredictions(testdata) + predictions(testdata);
        countpredictions(testdata) = countpredictions(testdata) + 1;
        avgforward_prob(testdata, :) = avgforward_prob(testdata, :) + forward_prob(testdata, :);
        countforward_prob(testdata) = countforward_prob(testdata) + 1;
    end
    accuracy = mean(allaccuracy);
    predictions = avgpredictions ./ max(countpredictions, ones(datasize, 1));
    forward_prob = avgforward_prob ./ max(countforward_prob, ones(datasize, 1));
    clear alldata allaccuracy avgpredictions countpredictions avgforward_prob countforward_prob;
    
    fPred = figure('Name','Discrete Predictions','NumberTitle','off');
    statePlot(data(testdata, :), predictions(testdata), Sn, Hn, Wn);
    
    fProb = figure('Name', 'Forward Probabilities', 'NumberTitle', 'off');
    forwardProbPlot(data(testdata, :), forward_prob(testdata, :), Sn, Hn, Wn);
end