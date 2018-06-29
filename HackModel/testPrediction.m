function [accuracy, predictions, A, B, state] = testPrediction(data, Sn, Hn, Wn, separator, maxIteration)
    
    if nargin < 6
        maxIteration = 10;
        if nargin < 5
            separator = 0.75;
        end
    end

    hvaccheckdata(data, Sn, Hn, Wn);
    
    datasize = size(data, 1);
    separator_index = max(datasize - 17520, round(separator * datasize));
    traindata = 1 : separator_index;
    testdata = separator_index : datasize;
    
    clear separator_index;

    [A, B] = HackModel(data(traindata, :), Sn, Hn, Wn, On, maxIteration, true);
    
    prev_forward_prob = [data(trainsize, 1) == 0, data(trainsize, 1) == 1];
    
    new_data = hvacpredict(prev_forward_prob, A, B, data(testdata, :), Sn, Hn, Wn);
    
    % to be finished
end