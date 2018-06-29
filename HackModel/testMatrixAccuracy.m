%% test accuracy

accuracyT = zeros(100, 1);
accuracyE = zeros(100, 1);
for i = 1 : 100
    [accuracyT(i), accuracyE(i)] = testRandMatrix(3, 48, 2);
end

fprintf('Accuracy of Transition matrix: %f\n', mean(accuracyT));
fprintf('Accuracy of Emission matrix: %f\n', mean(accuracyE));