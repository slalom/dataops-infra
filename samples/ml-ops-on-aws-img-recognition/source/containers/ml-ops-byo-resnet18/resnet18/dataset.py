import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator

prefix = "/opt/ml/"

input_path = prefix + "input/data"
WIDTH, HEIGHT, CHANNELS = int(4000/5), int(6000/5), 3


def read_dataset(image_dir, batch_size, train_mode=True, dataset=True, shuffle=True, binary_classification=False):
    def make_generator():
        image_generator = None
        class_mode = 'binary' if binary_classification else 'categorical'

        if train_mode:
            image_generator = ImageDataGenerator(
                rescale=1./255,
                shear_range=0.2,
                zoom_range=0.2,
                horizontal_flip=True,
                vertical_flip=True,
                rotation_range=30)
        else:
            image_generator = ImageDataGenerator(
                rescale=1./255,
                horizontal_flip=False,
                vertical_flip=False)

        image_generator = image_generator.flow_from_directory(
            image_dir,
            target_size=(HEIGHT, WIDTH),
            color_mode='rgb',
            batch_size=batch_size,
            class_mode=class_mode,
            shuffle=shuffle)

        return image_generator
    if dataset:
        if binary_classification:
            return tf.data.Dataset.from_generator(make_generator, output_types=(tf.float32, tf.uint8),
                                                  output_shapes=(tf.TensorShape((None, HEIGHT, WIDTH, CHANNELS)), tf.TensorShape((None,))))
        else:
            return tf.data.Dataset.from_generator(make_generator, output_types=(tf.float32, tf.uint8),
                                                  output_shapes=(tf.TensorShape((None, HEIGHT, WIDTH, CHANNELS)), tf.TensorShape((None, 3))))
    else:
        return make_generator()
