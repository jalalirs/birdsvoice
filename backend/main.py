from tensorflow.keras.models import Model
from tensorflow.keras.layers import Flatten, Dense, Input
from tensorflow.keras.applications import VGG19
from tensorflow.keras.preprocessing.image import img_to_array
import tensorflow.keras.losses as losses
from tensorflow.keras.preprocessing import image
from flask import Flask, request
import numpy as np
import os
import noisereduce as no
import warnings
warnings.filterwarnings('ignore')
import json
from core import BIRDS,create_spectrogram
import librosa 
import noisereduce as no
import json


THIS_DIR = os.path.dirname(os.path.realpath(__file__))

MODEL_WEIGHTS =  os.path.join(THIS_DIR, 'models/vgg19_5classes_2.h5')
classes = {i:k for i,k in enumerate(BIRDS)}
ALLOWED_EXTENSIONS = {'wav','mp3','m4a'}

app = Flask(__name__)
#app.secret_key = ""

model = None

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def load_model():
    global model
    input_size = (200,200,3)
    output_size = 5
    def get_categorical_accuracy_keras(y_true, y_pred):
        import tensorflow.keras.backend as K
        return K.mean(K.equal(K.argmax(y_true, axis=1), K.argmax(y_pred, axis=1)))
    inp = Input(shape=input_size)
    vgg_19 = VGG19(include_top=False, weights='imagenet', input_tensor=inp)
    x = vgg_19.output
    x = Flatten()(x)
    x = Dense(1024, activation='relu')(x)
    output = Dense(output_size, activation='softmax')(x)
    model = Model(inputs=inp, outputs=output)
    model.compile(loss=losses.categorical_crossentropy, optimizer='adam', metrics=[get_categorical_accuracy_keras])
    model.load_weights(MODEL_WEIGHTS)

def path_to_tensor(img_path):
    # loads RGB image as PIL.Image.Image type
    img = image.load_img(img_path)

    # convert PIL.Image.Image type to 3D tensor with shape (224, 224, d)
    imgarray = image.img_to_array(img)
    
    # convert 3D tensor to 4D tensor with shape (1, 224, 224, d) and return 4D tensor
    return np.expand_dims(imgarray, axis=0)

def transform(audiofile,prefix):
    """Transform audio file to spectrogram"""
    fname = audiofile.split("/")[-1].split(".")[0]
    mlpath = f"{prefix}/{fname}"
    y, sr = librosa.load(audiofile,mono=True)
    y = no.reduce_noise(audio_clip=y, noise_clip=y, verbose=False) 
    step = 10*sr 
    size = len(y)
    minimum = 5*sr
    create_spectrogram(y[0:step],sr,f"{mlpath}.jpg")
    tensor = path_to_tensor(f"{mlpath}.jpg")
    os.remove(f"{mlpath}.jpg") 
    os.remove(audiofile)
    return tensor


def create_result(prediction):
    ''' creates results (bird class and probability) ''' 

    top = np.argsort(prediction[0])[:-5:-1]
    result = []
    for i,t in enumerate(top):
        name = classes[top[i]]
        prob = round(prediction[0][top[i]],2)*100 
        result.append({"name": name , "probability": prob})
    return json.dumps(result,indent=4)




def predict(image):
    ''' makes prediction out of the spectrogram '''
    pred = model.predict(image)
    return pred


 
@app.route("/prediction", methods=["POST"]) 
def prediction():
    ''' makes prediction (uploads file, creates spectrogram, applies neural networks) '''
    print(request.files)
    file = None
    file = request.files['file']

    if not file or file.filename == '':
        return 'No selected file'
    elif file and not allowed_file(file.filename):
        return 'Wrong file format'
    

    with open(f"received/audio/{file.filename}", "wb") as f:
        f.write(file.read())
    image = transform(f"received/audio/{file.filename}","received/mlspec")

    pred = predict(image)
    result = create_result(pred)
    print(result)
    return result
                                                                      
      

if __name__ == '__main__':
    load_model()
    app.run(host='192.168.100.15',port=8080)

