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