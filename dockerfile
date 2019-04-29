FROM tensorflow/tensorflow:latest-py3
ENV DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
RUN apt-get update && apt-get install -y unzip git-core tmux wget protobuf-compiler python3 python-dev python3-dev build-essential libssl-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev python-pip
RUN git clone https://github.com/esimkowitz/mirror-detector.git /notebooks/mirrors
RUN git clone https://github.com/tensorflow/models.git /notebooks/mirrors/models
WORKDIR "/notebooks/mirrors"
RUN pip install -r ./requirements.txt
RUN chmod +x ./setup.sh
RUN ./setup.sh
CMD ["/run_jupyter.sh"]

