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

### 4/29/2019

Today I automated more of the Docker setup and cloned some of the O'Reilly tutorial's resources to this repo so that I could make changes. I spent some time today actually learning the Docker CLI so that I understood what exactly I was doing, which helped me learn that I was misusing `docker run` and actually creating a new container every time I called it. I had a lot of containers to clean up... Oops. I also annotated one of the images (not in this repo) and tried to train the model, though I ran into some dependency issues that I haven't entirely solved yet. I'll make more progress later in the week.

My plan hasn't really changed from yesterday, if anything I'm more confident today that this is possible than yesterday.

### 5/6/2019

I took and annotated more photos today. Now I'm ready to attempt to train the object detection model. The first step for this is to mount my images directory as a volume in my docker container:

```shell
sudo docker run -it -p 8888:8888 -p 6006:6006 --rm -v ~/shared:/notebooks/mirrors/shared --net=host mirror_detector_img bash
```

I then attempted to run the following command to convert my [LabelImg](https://github.com/tzutalin/labelImg) output to TFRecord:

```shell
python create_pascal_tf_record.py --data_dir=/notebooks/mirrors/shared/test-photos/annotations/ --output_path=/notebooks/mirrors/shared/test.record
```

This threw an error: `No module named 'object_detection'`, which I found a solution to [here](https://github.com/tensorflow/models/issues/2031). I'm going to add this to the Dockerfile for future builds:

```shell
# From the /notebooks/mirrors/models/research directory
python setup.py build
python setup.py install
```

I now tried running the `create_pascal_tf_record.py` program again but got a different error. I found [this _other_ tutorial](https://gist.github.com/douglasrizzo/c70e186678f126f1b9005ca83d8bd2ce) that's specific to using LabelImg. It seems like I need some more annotated examples to differentiate between training and evaluation... I guess it's back to labeling... Will update later.