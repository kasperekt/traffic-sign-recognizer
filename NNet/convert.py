import coremltools
import keras


def main():
    model = keras.models.load_model('model.h5')
    coreml_model = coremltools.converters.keras.convert(
        model, image_input_names='input')
    coreml_model.save('traffic-sign-model.mlmodel')


if __name__ == '__main__':
    main()
