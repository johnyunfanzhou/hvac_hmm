function [accuracy, predictions, fPred, fProb, A, B, state] = testPrediction(data, Sn, Hn, Wn, mode, testPercentage, maxIteration, supressOutput)
    
    if nargin < 8
        supressOutput = true;
        if nargin < 7
            maxIteration = 10;
            if nargin < 6
                testPercentage = 0.25;
                if nargin < 5
                    mode = 'clus';
                end
            end
        end
    end

    hvaccheckdata(data, Sn, Hn, Wn);
    
    datasize = size(data, 1);
    testsize = min([datasize - 1, 17520, round(testPercentage * datasize)]);
    
    if isequal(mode, 'rand')
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
    elseif isequal(mode, 'clus')
        traindata = 1 : datasize - testsize;
        testdata = datasize - testsize + 1 : datasize;
        [A, B, state] = HackModel(data(traindata, :), Sn, Hn, Wn, maxIteration, true);
        [new_data, forward_prob] = hvacpredict(A, B, data, Sn, Hn, Wn, testdata, supressOutput);
        predictions = new_data(:, 1);
        accuracy = 1 - sum(abs(predictions(testdata) - data(testdata, 1)))/testsize;
    else
        error('Unacceptable testing mode. Testing mode has to be ''rand'', ''clus'' or ''days''');
    end
    
    fPred = figure('Name','Discrete Predictions','NumberTitle','off');
    statePlot(data(testdata, :), predictions(testdata), Sn, Hn, Wn);
    
    fProb = figure('Name', 'Forward Probabilities', 'NumberTitle', 'off');
    forwardProbPlot(data(testdata, :), forward_prob(testdata, :), Sn, Hn, Wn);
end