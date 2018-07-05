function [accuracy, predictions, fPred, fProb, A, B, state] = testPrediction(data, Sn, Hn, Wn, separator, maxIteration, supressOutput)
    
    if nargin < 7
        supressOutput = true;
        if nargin < 6
            maxIteration = 10;
            if nargin < 5
                separator = 0.75;
            end
        end
    end

    hvaccheckdata(data, Sn, Hn, Wn);
    
    datasize = size(data, 1);
    s_index = max(datasize - 17520, round(separator * datasize));
    traindata = 1 : s_index;
    testdata = s_index + 1 : datasize;

    [A, B, state] = HackModel(data(traindata, :), Sn, Hn, Wn, maxIteration, true);
    
    prev_forward_prob = [data(s_index, 1) == 0, data(s_index, 1) == 1];
    
    [new_data, forward_prob] = hvacpredict(prev_forward_prob, A, B, data(testdata, :), Sn, Hn, Wn, 1, supressOutput);
    
    predictions = new_data(:, 1);
    
    accuracy = 1 - sum(abs(predictions - data(testdata, 1)))/(datasize - s_index);
    
    fPred = figure('Name','Discrete Predictions','NumberTitle','off');
    statePlot(data(testdata, :), predictions, Sn, Hn, Wn);
    
    fProb = figure('Name', 'Forward Probabilities', 'NumberTitle', 'off');
    forwardProbPlot(data(testdata, :), forward_prob, Sn, Hn, Wn);
end