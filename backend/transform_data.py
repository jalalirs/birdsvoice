from core import mkdir,create_spectrogram,BIRDS
import glob 
import librosa
import noisereduce as no

def get_files(root):
	files = {}
	birds = [a.strip("/").split("/")[-1] for a in glob.glob(f"{root}/*")]
	for b in birds:
		files[b] = glob.glob(f"{root}/{b}/*.mp3")
	return files

def make_dirs(prefix):
	mkdir(prefix)
	for i,b in enumerate(BIRDS):
		mkdir(f"{prefix}/{i}_{b}")

def _transform(mp3file,prefix):
	fname = mp3file.split("/")[-1].split(".")[0]
	mlpath = f"{prefix}/{fname}"
	y, sr = librosa.load(mp3file,mono=True)
	y = no.reduce_noise(audio_clip=y, noise_clip=y, verbose=False) 
	step = 10*sr 
	size = len(y)
	minimum = 5*sr
	count = 0
	for start, end in zip(range(0,size,step),range(step,size,step)):
		if end-start > minimum:
			sp = create_spectrogram(y[start:end],sr,f"{mlpath}_{count}.jpg")
			count += 1

def transform(files,prefix):
	for i,bird in enumerate(BIRDS):
		birdfiles = files[bird]
		for f in birdfiles:
			_transform(f,f"{prefix}/{i}_{bird}/")


if __name__ == '__main__':
	import argparse
	parser = argparse.ArgumentParser(description='Transform data from audio to spectrogram')
	parser.add_argument('--data_root',help='path to audio data')
	parser.add_argument('--prefix',help='path to store data')

	args = parser.parse_args()
	
	files = get_files(args.data_root)
	make_dirs(args.prefix)
	transform(files,args.prefix)