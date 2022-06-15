import tensorflow as tf

#!!!!!!!!!!!!!!!!!!!!!model freeze!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#Build a CNN classifier model using the Sequential API
def get_cnn_model(shape):
    """
    data.shape = [samples, frame_size, MFCCs]
    """
    cnn_model = tf.keras.Sequential([
        tf.keras.layers.Conv2D(filters=4, kernel_size=(3,3), activation="relu", input_shape=shape, padding="valid",
                               kernel_regularizer=tf.keras.regularizers.l1_l2(l1=1e-5, l2=1e-4)),
        tf.keras.layers.MaxPool2D(pool_size=(2,2),  strides=(2,2), padding="valid"),

        tf.keras.layers.Conv2D(filters=8, kernel_size=(3,3), activation="relu", padding="valid",
                               kernel_regularizer=tf.keras.regularizers.l1_l2(l1=1e-5, l2=1e-4)),
        tf.keras.layers.MaxPool2D(pool_size=(2,3), strides=(2,3), padding="valid"),
        

        tf.keras.layers.Flatten(),
        tf.keras.layers.Dense(64, activation="relu", kernel_regularizer=tf.keras.regularizers.l1_l2(l1=1e-5, l2=1e-4)),
        tf.keras.layers.Dense(10, activation="softmax", kernel_regularizer=tf.keras.regularizers.l1_l2(l1=1e-5, l2=1e-4))
    ])
    return cnn_model


#Build a CNN classifier model using the Sequential API
def get_mlp_model(shape):
    model = tf.keras.Sequential([
        tf.keras.layers.Flatten(input_shape=shape),
        tf.keras.layers.Dense(64, activation="relu",  kernel_regularizer=tf.keras.regularizers.l1_l2(l1=1e-5, l2=1e-4)),
        tf.keras.layers.Dense(32, activation="relu",  kernel_regularizer=tf.keras.regularizers.l1_l2(l1=1e-5, l2=1e-4)),
        tf.keras.layers.Dense(10, activation="softmax",  kernel_regularizer=tf.keras.regularizers.l1_l2(l1=1e-5, l2=1e-4),)
    ])
    return model

