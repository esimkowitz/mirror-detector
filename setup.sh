# This script is mostly to add missing dependencies needed to run the official TensorFlow Object Detection API examples in:
# https://github.com/tensorflow/models/tree/master/research/object_detection
cd ~

# COCO API installation
git clone https://github.com/cocodataset/cocoapi.git
cd cocoapi/PythonAPI
make
cp -r pycocotools /notebooks/mirrors/models/research/

# I was getting an error when compiling protobuf so I went with the manual install
cd /notebooks/mirrors/models/research
wget -O protobuf.zip https://github.com/google/protobuf/releases/download/v3.0.0/protoc-3.0.0-linux-x86_64.zip
unzip protobuf.zip
./bin/protoc object_detection/protos/*.proto --python_out=.

# Add Libraries to PYTHONPATH
export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim

# Test the installation
python object_detection/builders/model_builder_test.py