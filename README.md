# mirror-detector

Using TensorFlow Object Detection to identify mirrors in an image

## Setup

I currently have a Docker container set up with Tensorflow and Python 3, as well as all the requirements to run the Tensorflow Object Detection API. I set this up using [this tutorial](https://www.oreilly.com/ideas/object-detection-with-tensorflow), which comes with a preconfigured Dockerfile.
The `docker run` command in the tutorial gave me issues when trying to start the Jupyter notebook so I had to modify it:

```shell
sudo docker run -it -p 8888:8888 -p 6006:6006 --net=host object_dockerfile bash
```

The jupyter notebook included in the tutorial appears to be incomplete so I'm now using [Google's own object detection tutorial](https://github.com/tensorflow/models/tree/master/research/object_detection) which is downloaded by the Dockerfile into `/notebooks/object/models`. I had to follow some of the installation instructions there to fix some missing dependencies:
```shell
# Install dependencies from apt-get
apt-get install python3 python-dev python3-dev build-essential libssl-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev python-pip unzip

cd ~

# I was getting an error when compiling the pycocotools and the suggestion I found online was to install Cython
pip install Cython

# COCO API installation
git clone https://github.com/cocodataset/cocoapi.git
cd cocoapi/PythonAPI
make
cp -r pycocotools /notebooks/object/models/research/

# I was getting an error when compiling protobuf so I went with the manual install
cd /notebooks/object/models/research
wget -O protobuf.zip https://github.com/google/protobuf/releases/download/v3.0.0/protoc-3.0.0-linux-x86_64.zip
unzip protobuf.zip
./bin/protoc object_detection/protos/*.proto --python_out=.

# Add Libraries to PYTHONPATH
export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim

# Test the installation
python object_detection/builders/model_builder_test.py
```

When I have confirmed that this all works/is necessary for the mirror detection, I'll make some revisions to the dockerfile and add these to it.

## Current plan

My current plan is to use this container to train and run an object detection model. I have 200 or so sample mirrors and the ability to generate about 500 more if I need to. Now I'm going to work through the tutorial mentioned above to train the object detection model.

Since the first tutorial didn't work, I moved to using Google's tutorial, which is linked in the setup section. I successfully ran the quick start notebook from that tutorial and now I'm working my way through [a model training tutorial](https://towardsdatascience.com/how-to-train-your-own-object-detector-with-tensorflows-object-detector-api-bec72ecfe1d9). If all goes well, I'll try training the model for the mirrors. 

Originally I thought I could just give the training program 200 images of the mirrors, which would've been nice. I even was able to slice up one of the images I took of the mirror array so that I could get the 200 unique images of mirrors. It's looking, though, like I may have to do some actual annotating of the images to show it where each mirror is. This may be more cumbersome so I may wait until I have less to do.
