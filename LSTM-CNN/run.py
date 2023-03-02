import os
import json
import numpy as np
from core.process_data import DataLoad
from core.process_model import Model

run_tOlr = ['1s(0.8)']
run_m = [
    'orig',
    'morp'
]
run_groupSet = [
    '(1,3)',
    '(2,4)',
    '(w,s)'
]
run_channel = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30'
]
run_LSTM = ['LSTM(2,26)']

allData = []
for r1 in range(len(run_tOlr)):
    for r2 in range(len(run_m)):
        for r3 in range(len(run_groupSet)):
            for r4 in range(len(run_channel)):
                for r5 in range(len(run_LSTM)):

                    allData.append(run_tOlr[r1] + run_m[r2] + run_groupSet[r3] + 'ch(' + run_channel[r4] + ')' + run_LSTM[r5])

allEpochs = [
    1,
    64,
    1024
]

# allData = []
# allEpochs = []
# allData = ["1s(0.8)orig(1,3)ch(06)LSTM(2,26)"]
# allEpochs = [64]

configs = json.load(open('config.json', 'r'))

modelPathAll = configs['model']['save_dir']
if not os.path.exists(modelPathAll):
    os.makedirs(modelPathAll)

resultsPathAll = os.path.join(configs['model']['save_dir'], 'results')
if not os.path.exists(resultsPathAll):
    os.makedirs(resultsPathAll)

for iData in range(len(allData)):

    tempData = allData[iData]

    resultsName = tempData + ".txt"
    resultsPath = os.path.join(resultsPathAll, resultsName)
    if not os.path.isfile(resultsPath):

        tempDataAll = allData[iData][:19] + 'all' + allData[iData][21:]
        modelPathTempData = os.path.join(modelPathAll, tempDataAll)
        if not os.path.exists(modelPathTempData):
            os.makedirs(modelPathTempData)

        nEpochs = allEpochs.__len__()
        results = np.zeros((nEpochs, 7))
        for iEpochs in range(nEpochs):

            tempEpochs = allEpochs[iEpochs]
            configs = json.load(open('config.json', 'r'))

            if configs['data']['filename'] == "":
                configs['data']['filename'] = tempData + ".mat"

            if configs['training']['epochs'] == "":
                configs['training']['epochs'] = tempEpochs

            data = DataLoad(
                os.path.join('data', configs['data']['filename']),
                configs['data']['n_class']
            )

            modelName = configs['model']['name'] + "-epochs(" + str(configs['training']['epochs']) + ").h5"
            modelPath = os.path.join(modelPathTempData, modelName)

            if os.path.isfile(modelPath):
                model = Model()
                model.load_model(modelPath)
            else:
                model = Model()
                train_data = []
                train_label = []

                for iTempData in range(len(run_channel)):

                    tempTempData = allData[iData+iTempData]
                    dataTemp = DataLoad(
                        os.path.join('data', tempTempData + ".mat"),
                        configs['data']['n_class']
                    )

                    dataTemp.data_show()
                    print(' ')

                    if iTempData == 0:
                        train_data = dataTemp.train_data
                        train_label = dataTemp.train_label
                    else:
                        train_data = np.vstack((train_data, dataTemp.train_data))
                        train_label = np.vstack((train_label, dataTemp.train_label))

                input_timesteps = train_data.shape[1]
                input_dim = train_data.shape[2]

                model.build_model(configs, input_timesteps, input_dim, configs['data']['n_class'])

                model.train_model(
                    model_name=configs['model']['name'],
                    train_data=train_data,
                    train_label=train_label,
                    epochs=configs['training']['epochs'],
                    batch_size=configs['training']['batch_size'],
                    save_dir=modelPathTempData
                )

            test_data = data.test_data
            test_label = data.test_label
            predictions = model.test_model(test_data, test_label)

            print(test_label)
            print(' ')
            print(predictions)
            print(' ')

            nRight = 0
            nPredictions = predictions.shape[0]
            allMeanSquaredError = np.zeros((nPredictions, 1))
            allCrossEntropy = np.zeros((nPredictions, 1))
            TN = 0
            FP = 0
            TP = 0
            FN = 0
            for iPredictions in range(nPredictions):

                tempI = test_label[iPredictions].argmax()
                tempJudge = (predictions[iPredictions] < predictions[iPredictions, tempI])
                tempJudge[tempI] = True
                if tempJudge.all():
                    nRight = nRight + 1

                allMeanSquaredError[iPredictions, 0] = sum((predictions[iPredictions] - test_label[iPredictions])**2)
                allCrossEntropy[iPredictions, 0] = -(np.dot(test_label[iPredictions], np.log(predictions[iPredictions])))

                if configs['data']['n_class'] == 2:
                    if test_label[iPredictions, 0] == 1:
                        if tempJudge.all():
                            TN = TN + 1
                        else:
                            FP = FP + 1
                    if test_label[iPredictions, 1] == 1:
                        if tempJudge.all():
                            TP = TP + 1
                        else:
                            FN = FN + 1

            ClassificationError = 1 - (nRight/nPredictions)
            MeanSquaredError = sum(allMeanSquaredError)/nPredictions
            CrossEntropy = sum(allCrossEntropy)/nPredictions

            results[iEpochs, 0] = ClassificationError
            results[iEpochs, 1] = MeanSquaredError
            results[iEpochs, 2] = CrossEntropy
            results[iEpochs, 3] = TN
            results[iEpochs, 4] = FP
            results[iEpochs, 5] = TP
            results[iEpochs, 6] = FN

        np.savetxt(resultsPath, results, delimiter=',')
    else:
        results = np.loadtxt(resultsPath, delimiter=',')

    print(results)
