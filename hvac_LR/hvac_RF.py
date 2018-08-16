import hvac_LoadData as ld;
from sklearn.model_selection import train_test_split;
from sklearn.ensemble import RandomForestClassifier;
import scipy.io;

for k in [0, 1, 2, 3]:
    print('Random Forest Linear Model of Order %d:' % k);
    result_list = [];
    for test_number in [1, 2, 3, 4, 5]:
        print('Train test set %d:' % test_number);

        err = [];
        g = [];
        
        for FileIndex in range (25):
        
            # randomly sample test data
            # data = ld.load_data(FileIndex);
            # X = ld.generate_features(data, k);
            # y = ld.generate_labels(data, k);
            # X_train, X_test, y_train, y_test = train_test_split(X, y);
            
            # deleting discontinuous data
            X_train, X_test, y_train, y_test = ld.load_tts(FileIndex, k, test_number);
            
            # fill discontinuities with zero's
            # X_train, X_test, y_train, y_test = ld.load_tts(FileIndex, k, FILL = True);
            
            # fill discontinuities with most likely observations from the training set
            # X_train, X_test, y_train, y_test = ld.load_tts(FileIndex, k);
            # X_train, X_test, y_train, y_test = ld.load_tts(FileIndex, k, HISTORY = ld.HISTORY(X_train, y_train));
            
            RF = RandomForestClassifier();
            RF.fit(X_train, y_train);
            
            for key in X_test.keys():
                errors = 0;
                predictions = RF.predict(X_test[key]);
                for i in range (len(predictions)):
                    if (predictions[i] != y_test[key][i]):
                        errors += 1;
                err.append(errors);
                g.append(FileIndex + 1);
        
        print('Average prediction error is %f errors per day' % (sum(err) / len(err)));
        result_list.append(sum(err) / len(err));
    
        # scipy.io.savemat('tts' + str(test_number) + '_rf' + str(k) + '.mat', {'err': err, 'g': g});
        
    print('95%% confidence interval is (%.3f , %.3f).' % ld.CI95(result_list));