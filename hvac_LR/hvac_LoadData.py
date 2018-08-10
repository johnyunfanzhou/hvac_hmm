import os;
import csv;

filename = ['1d0733906f57440ecade6f8d3f091630de8c24ec.csv', 
    '5a582fd2839fc31dbc553389cf8e65b8b845aa7c.csv', 
    '6d195551c1ef0ca9bf855903cdfd9dd6b71a6ff5.csv', 
    '7a805f75e7a914388de0fb8308227c7ba627271c.csv', 
    '8bb1a09d4729c4908f4a7dfc173de7f7d0d3642c.csv', 
    '11e9aff05e9dadce7aa8292f13fe7187ea5a3037.csv', 
    '78c451cc556e71801bc66686fbc075cdd895dde6.csv', 
    '80b98d4c69fc7c6d89facafb1580454016f46f20.csv', 
    '83ed059e2bd6f36735a871c924fa74caa55f4878.csv', 
    '110dda328a521cd41d3771feaf994a9faa966b1e.csv', 
    '3200f9aa03bfedc80533b273d6dc2de839f8343e.csv', 
    '7310f1a63efce1496ad98bb8149a05e93ad4292f.csv', 
    '84607b6dce9e34641814db21a0bb5882d5375814.csv', 
    'a722b876dcf882b0c0412d535ab98943cd4a1846.csv', 
    'ab23b4f49689c5dd4bf205210bf3877126b115ef.csv', 
    'ac37d357c0d4436d5077a6c91a4634939514086f.csv', 
    'ae064b908ecfc8ec21028722ed86661c2b59d7c7.csv', 
    'c0d48ccbe55cc94acdebe3b4b5f35dd85e92b26a.csv', 
    'd805f6abf5c22a5e0582b29905468f735682ea0d.csv', 
    'd6753e2c7717cda160070bed00183cb722951f5f.csv', 
    'dd489fa33b229e50a89170159107ab2c3ca7369d.csv',  
    'e56deb5addea10ecc6b962cb2e8f4a57442b52ee.csv', 
    'e79039a7615153cfebfda4669160c06ad3a5658d.csv', 
    'f17826dce7c323c15e8f1e91cb7543f10b09520d.csv', 
    'fb4d3fa98447464e0d38ba15b6928ed5ca072eef.csv'];
    
def load_data(FileIndex):
    '''
    Read CSV file and return all entries in a matrix
    '''
    if ((FileIndex < 0) or (FileIndex > 24)):
        raise ValueError('Invalid file index.');
        
    result = [];
    
    os.chdir('../../formed_data/tts_1/continuous_sample/');

    with open(filename[FileIndex], 'r', newline = '') as csvfile:
        reader = csv.reader(csvfile, delimiter = ',');
        first = True;
        for row in reader:
            '''
            Ignore first row
            '''
            if first:
                first = False;
                continue;
            row[1] = int(row[1]);
            row[2] = int(row[2]);
            row[3] = int(row[3]); 
            row[4] = int(row[4]);
            if not (row in result):
                result.append(row);
    os.chdir(os.path.dirname(__file__))
    return result;
    
def generate_features(data, k, HISTORY = None, FILL = False, IncDATE = True):
    '''
    Given training data (data) and training order (k),
    output the feature matrix
    If discontinuous data is detected, use history average (HISTORY) to guess 
    the missing data.
    If there is no history average (HISTORY == None) but FILL == True, 
    discontinuous entries are filled with zeros; otherwise the sample is 
    deleted.
    If IncDATE = True, the function will reture X, date, where date is a list of 
    strings in the format 'YYYY-MM-DD', telling the corresponding date of each 
    sample entry in X.
    '''
    datasize = len(data);
    X = [];
    date = [];
    for i in range (datasize):
        x = [];
        x.append(data[i][2]);
        x.append(data[i][3]);
        x.append(data[i][4]);
        n = i; # duplicate i as n; n will be used to loop the k history obs
        skip_assign = False; # boolean variable indicating if S, H, W should be 
                             # read from data
                             # set to False if previous data is continuous
                             # set to True if previous data is discontinuous
        datacontinuous = True;
        for j in range (k):
            if not skip_assign:
                s = data[n][2];
                h = data[n][3];
                w = data[n][4];
            if datacontinuous:
                if (n == 1):
                    datacontinuous = False;
                elif ((h - data[n - 1][3]) % 48 != 1): 
                    # if h not increasing by 1
                    datacontinuous = False;
                elif (h != 0):
                    if ((s != data[n - 1][2]) or (w != data[n - 1][4])):
                        # if h increased by 1, but s/w changed in the middle of 
                        # the day (i.e., we skipped exactly a day)
                        datacontinuous = False;
            if datacontinuous:
                x.append(data[n - 1][1]);
                n -= 1;
                skip_assign = False;
            else:
                h = (h - 1) % 48; # assume at the previous time step
                                  # s_(t-1), h_(t-1), w_(t-1) = s_t, h_t - 1, w_t
                skip_assign = True;
                if HISTORY == None:
                    if FILL:
                        x.append(0);
                    else:
                        break; # this case, the feature vectore will not have 
                               # suffient number of elements, and will not be 
                               # appended to the matrix.
                else:
                    x.append(HISTORY[(s, h, w)]);
        # append the feature vector (x) to the list if it is complete
        # if and only if HISTORY = None and FILL = False, x is not complete and 
        # will not be appended (will be discarded)
        if (len(x) == 3 + k):
            X.append(x);
            date.append(data[i][0][:10]);
    return X, date;

def generate_labels(data, k, HISTORY = None, FILL = False):
    '''
    Given training data (data) and training order (k),
    output the label vector
    HISTORY and FILL should be the same as those passed into the corresponding 
    generate_features function call to result in matching sample size.
    '''
    datasize = len(data);
    y = [];
    for i in range (datasize):
        n = i;
        datacontinuous = True;
        for j in range (k):
            if datacontinuous:
                if (n == 1):
                    datacontinuous = False;
                elif ((data[n][3] - data[n - 1][3]) % 48 != 1):
                    datacontinuous = False;
                elif (data[n][3] != 0):
                    if ((data[n][2] != data[n - 1][2]) or (data[n][4] != data[n - 1][4])):
                        datacontinuous = False;
            n -= 1;
        if datacontinuous:
            y.append(data[i][1]);
        else:
            if HISTORY == None and not FILL:
                continue;
            else:
                y.append(data[i][1]);
    return y;

def load_tts(FileIndex, k, HISTORY = None, FILL = False):
    '''
    Read CSV file and return X_train, X_test, y_train, y_test
    k is the order of the linear model
    If discontinuous data is detected, use history average (HISTORY) to guess 
    the missing data.
    If there is no history average (HISTORY == None) but FILL == True, 
    discontinuous entries are filled with zeros; otherwise the sample is 
    deleted.
    
    ****** BUG ******
    If len(X) != len(data), i.e.discontinuous data were deleted, then data[i] 
    and X[i] do not match each other. Testing dates were detected using data, 
    but entries in X were appended to the testing set; they may not necessarily 
    match in this case.
    
    '''
    data = load_data(FileIndex);
    X, date = generate_features(data, k, HISTORY, FILL, IncDATE = True);
    y = generate_labels(data, k, HISTORY, FILL);
    datasize = len(X);

    test_entries = [];
    
    os.chdir('../../formed_data/tts_1/test_1/');
    
    with open('test_' + filename[FileIndex], 'r', newline = '') as csvfile:
        reader = csv.reader(csvfile, delimiter = ',');
        first = True;
        for row in reader:
            '''
            Ignore first row
            '''
            if first:
                first = False;
                continue;
            test_entries.append(row[0][:10]);
    
    X_train = [];
    X_test = {};
    y_train = [];
    y_test = {};
    
    for i in range (datasize):
        if date[i] in test_entries:
            if date[i] not in X_test.keys():
                X_test[date[i]] = [];
                y_test[date[i]] = [];
            X_test[date[i]].append(X[i]);
            y_test[date[i]].append(y[i]);
        else:
            X_train.append(X[i]);
            y_train.append(y[i]);
    
    os.chdir(os.path.dirname(__file__));
    return X_train, X_test, y_train, y_test;
    
def HISTORY(X, y):
    '''
    Giving a list of features and labels,
    output the most likely observations for giving (s, h, w)
    return a dict: {(s, h, w): obs}
    '''
    count = [[0, 0] for a in range (3 * 48 * 2)];
    for i in range (len(X)):
        S = X[i][0];
        H = X[i][1];
        W = X[i][2];
        index = W + 2 * (H + 48 * S);
        count[index][y[i]] += 1;
    result = {};
    for s in range (3):
        for h in range (48):
            for w in range (2):
                index = w + 2 * (h + 48 * s);
                result[(s, h, w)] = count[index].index(max(count[index]));
    return result;