
FROM ubuntu:20.04

ENV LANG C.UTF-8
# setup timezone
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -qq update && apt-get upgrade -y
RUN apt-get -y install --no-install-recommends \
    sudo \
    build-essential \
    nasm \
    git \
    python3.9 \
    python3-dev \
    python3-pip \
    python3-venv \
    python3-setuptools \
    python3-wheel \
    python3-tk \
    libavformat-dev libavcodec-dev libavdevice-dev libavutil-dev \
    libavfilter-dev libswscale-dev libavresample-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists

RUN apt-get update -qq && apt-get install ffmpeg -y

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.9 2

RUN pip3 install --upgrade pip

WORKDIR "/vqm"

# COPY ./requirements.txt .
# RUN pip3 install -r ./requirements.txt

COPY . .

ENTRYPOINT ["python3","-m","vqm"]