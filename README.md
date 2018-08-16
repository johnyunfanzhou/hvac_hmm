# hvac_hmm
Private repository for HVAC Hidden Markov Model.

Three hvac models are included in theis repository:

* HVAC HMM with EM
* HVAC HMM with Viterbi EM
* HVAC Linear Models with LR and RF

## Setting up
All hvac data should be located under the `formed_data` folder. Specifically:

* `continuous_sample`, `train_1`, `test_1`, `train_2`, `test_2`, `train_3`, `test_3`, `train_4`, `test_4`, `train_5`, `test_5` of group of files with '1d073390... .csv' should be under the directory `formed_data/tts_1`
* `continuous_sample`, `train_1`, `test_1`, `train_2`, `test_2`, `train_3`, `test_3`, `train_4`, `test_4`, `train_5`, `test_5` of group of files with '1cca90ad... .csv' should be under the directory `formed_data/tts_2`

Change to the directory containing the `formed_data` folder and clone this repository there by executing

`$ git clone https://github.com/z2862658714/hvac_hmm`

## HVAC Linear Model with LR and RF
The code for this model is included in the `/HVAC_LR` subdirectory.

Change to the directory `/HVAC_LR` and execute

`$ python hvac_LR.py`

or

`$ python hvac_RF.py`

to generate the results.

### Configuring Linear Models
In hvac_LR.py or hvac_RF.py

* line 18 - 21: use `sklearn.model_selection.train_test_split` to randomly split train test set (instead of loading the 20 test days)
* line 24: delete the data affected by the discontinuities
* line 27: fill all discontinuous observations with zero
* line 30 - 31: missing data imputation: from the training data, for each given (S, H, W), determine the most occurred observation (0 or 1) in the training data; fill each discontinuous observation with the most occurred observation given (S, H, W).

Uncomment one of the above four sections and comment the other three to adjust the behavior of the linear model.

Uncomment line 48 to save the result as MAT files.

** Please do not hesitate to reach us on keybase if anything needs to be clarified! **