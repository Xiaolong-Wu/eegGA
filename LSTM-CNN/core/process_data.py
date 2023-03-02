import scipy.io as io
import numpy as np


def transdata(data, n_sample):
    data_new = []
    for r in range(n_sample):
        data_temp = data[r, 0]
        data_new.append(data_temp)
    return np.array(data_new)


def translabel(label, n_sample, n_class):
    label_new = np.zeros((n_sample, n_class))
    for r in range(n_sample):
        label_new[r, label[r]] = 1
    return label_new


class DataLoad:
    def __init__(self, filename, n_class):
        data = io.loadmat(filename)
        train_label = data['train_label']
        test_label = data['test_label']

        n_sample_train = len(train_label)
        n_sample_test = len(test_label)

        self.train_data = transdata(data['train_data'], n_sample_train)
        self.train_label = translabel(train_label, n_sample_train, n_class)
        self.test_data = transdata(data['test_data'], n_sample_test)
        self.test_label = translabel(test_label, n_sample_test, n_class)

    def data_show(self, verbose=False):
        if verbose:
            print(self.train_data)
            print(self.train_label)
            print(self.test_data)
            print(self.test_label)

        print('train_data: ', self.train_data.shape)
        print('train_label: ', self.train_label.shape)
        print('test_data: ', self.test_data.shape)
        print('test_label: ', self.test_label.shape)
