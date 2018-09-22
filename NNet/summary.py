from keras.utils import plot_model
from index import cnn_model


def main():
    model = cnn_model()
    plot_model(model, to_file='model.png',
               show_layer_names=False, show_shapes=True)


if __name__ == '__main__':
    main()
