# mirror-detector

Using TensorFlow Object Detection to identify mirrors in an image

## Setup

I currently have a Docker container set up with Tensorflow and Python 3, as well as all the requirements to run the Tensorflow Object Detection API. I set this up using [this fantastic tutorial](https://www.oreilly.com/ideas/object-detection-with-tensorflow), which comes with a preconfigured Dockerfile.
The `docker run` command in the tutorial gave me issues when trying to start the Jupyter notebook so I had to modify it:

```sudo docker run -it -p 8888:8888 -p 6006:6006 --net=host object_dockerfile bash```

## Current plan

My current plan is to use this container to train and run an object detection model. I have 200 or so sample images and the ability to generate about 500 more if I need to. Now I'm going to work through the tutorial mentioned above to train the object detection model.
