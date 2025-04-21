# In Python script
import tensorflow as tf

model = tf.keras.models.load_model("task_estimator_model")
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

with open("assets/model.tflite", "wb") as f:
    f.write(tflite_model)
