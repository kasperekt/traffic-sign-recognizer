import os
import coremltools
import keras
from label_map import *


APP_PROJECT_PATH = 'TrafficSignRecognizer/TrafficSignRecognizer'


def main():
    model = keras.models.load_model('model.h5')
    class_labels = list(label_map.values())

    coreml_model = coremltools.converters.keras.convert(
        model, input_names=['input'], output_names=['output'],
        class_labels=class_labels, image_input_names='input')
    coreml_model.save(os.path.join(APP_PROJECT_PATH,
                                   'trafficSignUpdated.mlmodel'))


if __name__ == '__main__':
    main()
