# mirror-detector

Using TensorFlow Object Detection to identify mirrors in an image. 

This is part of a larger research project to produce a mirror array that can distribute sunlight evenly to all parts of a room. One goal within this project is to use a camera to monitor the real-world orientations of the mirrors and compare these to the assumed orientations for each mirror, allowing the system to self-correct should the assumed- and the real-world-orientations not match. My specific goal is to take an image of the mirror array and identify the location of each mirror in the image and draw an ellipse around the mirror. Someone else will design a system to take these ellipses and calculate the orientation of each mirror and perform the compare-correct feedback loop.

Depending on performance, this system may be run on the edge or on a higher-performance (GPU-enabled) system, though we would like to do as much pre-processing on the edge as possible to reduce bandwidth.

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

### 4/27/2019

My current plan is to use this container to train and run an object detection model. I have 200 or so sample mirrors and the ability to generate about 500 more if I need to. Now I'm going to work through the tutorial mentioned above to train the object detection model.

Since the first tutorial didn't work, I moved to using Google's tutorial, which is linked in the setup section. I successfully ran the quick start notebook from that tutorial and now I'm working my way through [a model training tutorial](https://towardsdatascience.com/how-to-train-your-own-object-detector-with-tensorflows-object-detector-api-bec72ecfe1d9). If all goes well, I'll try training the model for the mirrors. 

Originally I thought I could just give the training program 200 images of the mirrors, which would've been nice. I even was able to slice up one of the images I took of the mirror array so that I could get the 200 unique images of mirrors. It's looking, though, like I may have to do some actual annotating of the images to show it where each mirror is. This may be more cumbersome so I may wait until I have less to do.

### 4/28/2019

After reading through the [model training tutorial](https://towardsdatascience.com/how-to-train-your-own-object-detector-with-tensorflows-object-detector-api-bec72ecfe1d9), it looks like the annotation process is fairly straight-forward, if a bit cumbersome. I am now going to annotate the images of the mirror arrays with the positions of each of the mirrors. I can use [LabelImg](https://github.com/tzutalin/labelImg) to do this and can then convert the annotated image dataset into the TFRecord format required by the model training program using [this script](https://github.com/tensorflow/models/blob/master/research/object_detection/dataset_tools/create_pascal_tf_record.py), which is provided by Google. There are a bunch of other dataset preparation scripts in that directory should someone use a different annotation program. 

I may need to take some more photos of the scene with different lighting conditions, but I'm first gonna try it with just the 8 or so photos I have now, which should give me more than 800 unique examples of the mirrors. I'm hoping to get most of this work done in the next week or so once I'm done with my other work.

Once the mirror detector part is complete, I can pipe the output into the [ellipse detector](https://github.com/h3ct0r/fast_ellipse_detector). I plan to make some modifications to this program so that I can pass in the bounding box for the mirrors, thereby limiting the search area for the ellipse by a factor of 200 or so. I'm then going to see about parallelizing the ellipse detection so that I can process all the mirrors in a photo rather than just one. Once I get the dimensions of the ellipses back, I think my work on this project will be complete and I'll hand it off.