# mirror-detector

Using TensorFlow Object Detection to identify mirrors in an image. 

This is part of a larger research project to produce a mirror array that can distribute sunlight evenly to all parts of a room. One goal within this project is to use a camera to monitor the real-world orientations of the mirrors and compare these to the assumed orientations for each mirror, allowing the system to self-correct should the assumed- and the real-world-orientations not match. My specific goal is to take an image of the mirror array and identify the location of each mirror in the image and draw an ellipse around the mirror. Someone else will design a system to take these ellipses and calculate the orientation of each mirror and perform the compare-correct feedback loop.

Depending on performance, this system may be run on the edge or on a higher-performance (GPU-enabled) system, though we would like to do as much pre-processing on the edge as possible to reduce bandwidth.

## Setup

I have supplied a [Dockerfile](/Dockerfile) with this repository which will setup a Docker image with all the necessary dependencies to run the [TensorFlow Object Detection API](https://github.com/tensorflow/models/tree/master/research/object_detection) and to train it with new images.

```shell
# Build a new Docker image using the provided Dockerfile
sudo docker build -t mirror_detector_img -f Dockerfile
# Start a container with the built image
sudo docker run -it -p 8888:8888 -p 6006:6006 --net=host mirror_detector_img bash
```

The Dockerfile also runs an additional script, [setup.sh](/setup.sh), which adds dependencies that the [official TensorFlow models repository recommended](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/installation.md) for running their example Jupyter notebooks, which can be found in the Docker container at `/notebooks/mirrors/models/research/object_detection`.

## Current plan

### 4/27/2019

My current plan is to use this container to train and run an object detection model. I have 200 or so sample mirrors and the ability to generate about 500 more if I need to. Now I'm going to work through the tutorial mentioned above to train the object detection model.

Since the first tutorial didn't work, I moved to using Google's tutorial, which is linked in the setup section. I successfully ran the quick start notebook from that tutorial and now I'm working my way through [a model training tutorial](https://towardsdatascience.com/how-to-train-your-own-object-detector-with-tensorflows-object-detector-api-bec72ecfe1d9). If all goes well, I'll try training the model for the mirrors. 

Originally I thought I could just give the training program 200 images of the mirrors, which would've been nice. I even was able to slice up one of the images I took of the mirror array so that I could get the 200 unique images of mirrors. It's looking, though, like I may have to do some actual annotating of the images to show it where each mirror is. This may be more cumbersome so I may wait until I have less to do.

### 4/28/2019

After reading through the [model training tutorial](https://towardsdatascience.com/how-to-train-your-own-object-detector-with-tensorflows-object-detector-api-bec72ecfe1d9), it looks like the annotation process is fairly straight-forward, if a bit cumbersome. I am now going to annotate the images of the mirror arrays with the positions of each of the mirrors. I can use [LabelImg](https://github.com/tzutalin/labelImg) to do this and can then convert the annotated image dataset into the TFRecord format required by the model training program using [this script](https://github.com/tensorflow/models/blob/master/research/object_detection/dataset_tools/create_pascal_tf_record.py), which is provided by Google. There are a bunch of other dataset preparation scripts in that directory should someone use a different annotation program. 

I may need to take some more photos of the scene with different lighting conditions, but I'm first gonna try it with just the 8 or so photos I have now, which should give me more than 800 unique examples of the mirrors. I'm hoping to get most of this work done in the next week or so once I'm done with my other work.

Once the mirror detector part is complete, I can pipe the output into the [ellipse detector](https://github.com/h3ct0r/fast_ellipse_detector). I plan to make some modifications to this program so that I can pass in the bounding box for the mirrors, thereby limiting the search area for the ellipse by a factor of 200 or so. I'm then going to see about parallelizing the ellipse detection so that I can process all the mirrors in a photo rather than just one. Once I get the dimensions of the ellipses back, I think my work on this project will be complete and I'll hand it off.