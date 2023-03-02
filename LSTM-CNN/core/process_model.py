import os
import datetime as dt
from core.utils import Timer
from keras.layers import Conv1D, Conv2D, LSTM, Dense, MaxPooling1D, MaxPooling2D, Flatten, Dropout, Activation
from keras.models import Sequential, load_model
from keras.callbacks import EarlyStopping, ModelCheckpoint


class Model:

    def __init__(self):
        self.model = Sequential()

    def load_model(self, filepath):
        print('[Model] Loading model from file %s' % filepath)
        self.model = load_model(filepath)
        print(' ')

    def build_model(self, configs, input_timesteps, input_dim, n_class):
        print('[Model] Building model...')
        r_layer = 0
        n_layer = len(configs['model']['layers'])
        for layer in configs['model']['layers']:
            r_layer = r_layer + 1

            neurons = layer['neurons'] if 'neurons' in layer else None
            if r_layer == n_layer:
                neurons = n_class
            activation = layer['activation'] if 'activation' in layer else None

            # conv1d
            kernel_num = layer['kernel_num'] if 'kernel_num' in layer else 1
            kernel_size = layer['kernel_size'] if 'kernel_size' in layer else 1
            strides = layer['strides'] if 'strides' in layer else 1
            # conv2d
            kernel_size_x = layer['kernel_size_x'] if 'kernel_size_x' in layer else 1
            kernel_size_y = layer['kernel_size_y'] if 'kernel_size_y' in layer else 1
            strides_x = layer['strides_x'] if 'strides_x' in layer else 1
            strides_y = layer['strides_y'] if 'strides_y' in layer else 1
            # lstm
            if r_layer != 1:
                input_timesteps = None
                input_dim = None
            return_seq = layer['return_seq'] if 'return_seq' in layer else None
            # maxpooling1d
            pool_size = layer['pool_size'] if 'pool_size' in layer else 1
            # maxpooling2d
            pool_size_x = layer['pool_size_x'] if 'pool_size_x' in layer else 1
            pool_size_y = layer['pool_size_y'] if 'pool_size_y' in layer else 1
            # dropout
            dropout_rate = layer['rate'] if 'rate' in layer else None

            if layer['type'] == 'conv1d':
                self.model.add(Conv1D(kernel_num, kernel_size, strides=strides, activation=activation))
            if layer['type'] == 'conv2d':
                self.model.add(Conv2D(kernel_num, (kernel_size_x, kernel_size_y), strides=(strides_x, strides_y), activation=activation))
            if layer['type'] == 'lstm':
                self.model.add(LSTM(neurons, input_shape=(input_timesteps, input_dim), return_sequences=return_seq))
            if layer['type'] == 'dense':
                self.model.add(Dense(neurons, activation=activation))
            if layer['type'] == 'maxpooling1d':
                self.model.add(MaxPooling1D(pool_size=pool_size,  strides=strides))
            if layer['type'] == 'maxpooling2d':
                self.model.add(MaxPooling2D(pool_size=(pool_size_x, pool_size_y),  strides=(strides_x, strides_y)))
            if layer['type'] == 'flatten':
                self.model.add(Flatten())
            if layer['type'] == 'dropout':
                self.model.add(Dropout(dropout_rate))

        self.model.compile(loss=configs['model']['loss'], optimizer=configs['model']['optimizer'])
        print(' ')

    def train_model(self, model_name, train_data, train_label, epochs, batch_size, save_dir):
        timer = Timer()
        timer.start()
        print('[Model] Training model...')
        print('[Model] %s epochs, %s batch size' % (epochs, batch_size))

        if model_name == "":
            save_fname = os.path.join(save_dir, '%s-epochs(%s).h5' % (dt.datetime.now().strftime('(%Y-%m-%d)(%H-%M-%S)'), str(epochs)))
        else:
            save_fname = os.path.join(save_dir, '%s-epochs(%s).h5' % (model_name, str(epochs)))
        callbacks = [
            EarlyStopping(monitor='val_loss', patience=5),
            ModelCheckpoint(filepath=save_fname, monitor='val_loss', save_best_only=True)
        ]
        self.model.fit(
            train_data,
            train_label,
            epochs=epochs,
            batch_size=batch_size,
            callbacks=callbacks
        )
        timer.stop()

        self.model.save(save_fname)
        print('[Model] Training completed. Model saved as %s' % save_fname)
        print(' ')

    def test_model(self, test_data, test_label):
        print('[Model] Predicting...')
        predicted = self.model.predict(test_data)

        print(' ')
        return predicted
