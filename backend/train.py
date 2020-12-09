from core import BIRDS
from tensorflow.keras.applications import VGG19 
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input,Dense, Flatten
from tensorflow.keras.callbacks import ReduceLROnPlateau, ModelCheckpoint
from sklearn.datasets import load_files
import numpy as np
from tqdm import tqdm
from keras.preprocessing import image
import tensorflow.keras.losses as losses

def path_to_tensor(img_path,target_size,mode):
    # loads RGB image as PIL.Image.Image type
    img = image.load_img(img_path, target_size=target_size)

    # convert PIL.Image.Image type to 3D tensor with shape (224, 224, d)
    imgarray = image.img_to_array(img)
    if mode == "gray":
        imgarray = gray(imgarray)
        w,h = imgarray.shape
        imgarray = np.repeat(imgarray,3).reshape((w,h,3))
    
    # convert 3D tensor to 4D tensor with shape (1, 224, 224, d) and return 4D tensor
    return np.expand_dims(imgarray, axis=0)

def paths_to_tensor(img_paths,target_size,mode):
    list_of_tensors = [path_to_tensor(img_path,target_size,mode) for img_path in tqdm(img_paths)]
    return np.vstack(list_of_tensors)


def load_dataset(path,target_size=(200,200)):
    """
    Load scikit-learn based image dataset given path, mode and target_size
    @mode: vector, gray, or color
    return data, and targets (integer values as read from images file names)
    """
    data = load_files(path)
    files = np.array(data['filenames'])
    targets= np.array(data["target"])
    
    data = paths_to_tensor(files,target_size,"color")

    return data, targets

def sample_from(lst, num):
	training = int(0.80*num)
	samples = [np.where(lst==i)[0][:num] for i in range(len(BIRDS))]
	trainingList = []
	testingList = []
	for s in samples:
		trainingList += s[:training].tolist()
		testingList += s[training:].tolist()
	return trainingList,testingList

def one_hot_encode(lst):
	b = np.identity(len(BIRDS))
	t = np.zeros((lst.shape[0],len(BIRDS)))
	for i,v in enumerate(lst):
		t[i] = b[v]
	return t

def get_categorical_accuracy_keras(y_true, y_pred):
    import tensorflow.keras.backend as K
    return K.mean(K.equal(K.argmax(y_true, axis=1), K.argmax(y_pred, axis=1)))

def build_model(inp,output):
    model = Model(inputs=inp, outputs=output)
    model.compile(loss=losses.categorical_crossentropy, optimizer='adam', metrics=[get_categorical_accuracy_keras])
    return model
    
def add_flatten(x,target_size):
    x = Flatten()(x)
    x = Dense(1024, activation='relu')(x)
    preds = Dense(target_size, activation='softmax')(x)
    return preds


if __name__ == '__main__':
	import argparse
	parser = argparse.ArgumentParser(description='Transform data from audio to spectrogram')
	parser.add_argument('--data_root',help='path to audio data')
	parser.add_argument('--sample_per_bird',default=500)
	parser.add_argument('--checkpoint',default=None)
	args = parser.parse_args()
	print("Loading dataset")
	data,targets = load_dataset(args.data_root)

	print(f"Sampling {args.sample_per_bird}/bird")
	trainingSample,validSample = sample_from(targets,args.sample_per_bird)

	training_data, training_targets = data[trainingSample],targets[trainingSample]
	valid_data, valid_targets = data[validSample],targets[validSample]
	training_targets_enc,valid_targets_enc = one_hot_encode(training_targets),one_hot_encode(valid_targets)

	print(f"Building model")
	input_size = list(training_data.shape)[1:]
	target_size = training_targets_enc.shape[1]

	inputLayer = Input(shape=input_size)
	vgg_19 = VGG19(include_top=False, weights='imagenet', input_tensor=inputLayer)
	outputLayer = vgg_19.output
	for layer in vgg_19.layers:
	    layer.trainable = False 
	model = build_model(vgg_19.inputs,add_flatten(outputLayer,target_size))
	

	ModelCheck = ModelCheckpoint(args.checkpoint, monitor='val_loss', verbose=0, 
                             save_best_only=True, save_weights_only=True, mode='auto', period=1)

	ReduceLR = ReduceLROnPlateau(monitor='val_loss', factor=0.2,
	                              patience=5, min_lr=3e-4)
	print(f"Training")
	model.fit(training_data,training_targets_enc, epochs=5, validation_data = (valid_data,valid_targets_enc), 
		verbose=True,callbacks=[ModelCheck,ReduceLR])


