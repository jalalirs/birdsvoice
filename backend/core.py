import librosa  
import librosa.display
import numpy as np
import os
import matplotlib  
matplotlib.use('Qt5Agg')
matplotlib.interactive(False)
import warnings
warnings.filterwarnings('ignore')
import matplotlib.pyplot as plt
from PIL import Image
import sklearn

BIRDS = [
"bulbul","dove","hoopoe","myna","sparrow"
]

def mkdir(path):
    if not os.path.exists(path):
        os.makedirs(path)

def fig2img(fig):
    ''' Transforms matplotlib figure to image '''
    fig.canvas.draw()
    w,h = fig.canvas.get_width_height()
    buf = np.fromstring(fig.canvas.tostring_argb(), dtype=np.uint8)
    buf.shape = (400,400,4)
    buf = np.roll(buf,3,axis = 2)
    w, h, d = buf.shape
    return Image.frombytes("RGB",(w,h),buf.tostring())


def normalize(x, axis=0):
    return sklearn.preprocessing.minmax_scale(x, axis=axis)

def create_spectrogram(signal,sr,filepath=None):
    N_FFT = 1024         # Number of frequency bins for Fast Fourier Transform
    HOP_SIZE = 1024      # Number of audio frames between STFT columns
    SR = 44100           # Sampling frequency
    N_MELS = 30          # Mel band parameters   
    WIN_SIZE = 1024      # number of samples in each STFT window
    WINDOW_TYPE = 'hann' # the windowin function
    FEATURE = 'mel'      # feature representation
    
    spectral_centroids = librosa.feature.spectral_centroid(y=signal, sr=sr)[0]
    frames = range(len(spectral_centroids))
    t = librosa.frames_to_time(frames)

    plt.rcParams['figure.figsize'] = (10,2)            
    fig = plt.figure(1,frameon=False)
    fig.set_size_inches(2,2)
    ax = plt.Axes(fig, [0., 0., 1., 1.])
    ax.set_axis_off()
    fig.add_axes(ax)
    
    spectogram = librosa.display.specshow(
             librosa.core.amplitude_to_db(
                librosa.feature.melspectrogram(
                                y=signal, 
                                sr=SR)),x_axis='time', y_axis='mel')
    plt.plot(t, normalize(spectral_centroids), color='r')
    image = fig2img(fig)
    if filepath:
        fig.savefig(filepath)
        fig.clear()   
    return image
