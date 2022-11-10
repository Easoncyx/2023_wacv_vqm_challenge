# 2023 WACV HDR Video Quality Measurement Grand Challenge

## Code submission

In order to get your final ranking on the private test set, you have to submit a valid runnable model using docker. You model can be a python or C/C++ or other executable console application that takes commands lines arguments as input. 

If your model is on Matlab or other platform that can not run inside docker. Please write it as python if possible and submit the docker repo. We only accept docker format submission for final evaluation.

## Hardware environment

All submitted docker solutions will be evaluated on a standard AWS EC2 instance (p3.2xlarge) with the following spec:

GPU: NVIDIA Tesla V100 GPU 16GB

CPU: 8 vCPU High frequency Intel Xeon Scalable Processor (Broadwell E5-2686 v4)

Memory: 61GB

Storage: EBS GP3 SSD 256 GB 



## Video decoding

The input distorted and reference HDR videos are all encoded with X265 in MP4 format in `yuv420p10le` format. You can use whatever works best for your model to decode the video and load images. If you need metadata such as video resolution and framerate etc, you can use ffprobe to parse the input MP4 video.

The `ffmpeg` and `ffprobe` are installed in this example `Dockerfile`. The following funtion is useful to parse the metadata from video where the `key` can be any string in this list: `[width, height, r_frame_rate, pix_fmt, display_aspect_ratio]`.

```python
def ffprobe_get_stream_info(in_video_path, key):
    cmd = f'ffprobe -threads 1 -v 0 -of compact=p=0:nk=1 -select_streams 0 -show_entries stream={key} "{in_video_path}"'
    ret = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT)
    ret = ret.decode('utf-8')
    return ret
```


You can convert the video to Y4M format and upsclae to the reference video resolution (2160p) if your model reads raw video input. If your FR model need the same resolution videos as input you can use whatever upscaling method works best for your model. For example, you can use the following command to decode and upscale to 2160p resolution using lanczos a=5 and output a Y4M video with FFMPEG.

```bash
ffmpeg -y -nostdin -hide_banner \
  -i {in_mp4_path} \
  -f yuv4mpegpipe \
  -pix_fmt yuv420p10le \
  -strict -1 \
  -vf scale=3840:2160 \
  -sws_flags lanczos+accurate_rnd+full_chroma_int \
  -sws_dither none \
  -param0 5 \
  {out_y4m_path}
```



## Docker submission guideline

### Python

For python application, the Dockerfile ENTRYPOINT should be your interpreter plus your scripts/module. For example, 

```dockerfile
ENTRYPOINT ["python3","./your_script.py"]
# or
ENTRYPOINT ["python3","-m","your_module"]
```

Within `your_script.py` or `your_module` `__main__.py` file, you can use `argparse` package or directly reading `sys.argv` to get the input video path as defined in section "Docker command line interface". 

If you need a template to start, an example python environment setup with some pre-installed packages (numpy, scipy, ffmpeg) and an empty python package named `vqm` is given in this repo. You don't have to use this example as long as your docker application follows the command line internface requirements.

In this example, [Poetry](https://python-poetry.org/docs/#installation) is used to config the local python virtual environment. You can used the following commands to manage packages you need and export them to the requirements file for Dockerfile to build the same environment. 
```bash
# create new vitrual environment
poetry install

# install package
poetry add numpy

# export to requirement.txt
poetry export -f requirements.txt --output requirements.txt

# to test your model locally without docker
poetry run vqm [pvs_video] [ref_video] [result_file]
```




### C/C++

For C/C++ application, you should build your application into binary executable console application in  Dockerfile and set the ENTRYPOINT to your application so that command line parameters can be passed into your program through docker run command.



### GPU Docker

If your model need to use GPU, you can modify the Dockerfile base image to use a GPU enabled Ubuntu image, for example, you can uncomment the 2nd line in the Dockerfile and comment out the 1st line by using `nvidia/cuda:11.6.2-base-ubuntu20.04` as base image.


### Docker command line interface

Please following the command line interface below:

For no reference (NR) model:

- 1st positional argument: `pvs_video` is the path to the input **distorted** MP4 video
- 2nd positional argument: `result_file` is the path to the location on the disk to write your result file



For full reference (FR) model:

- 1st positional argument: `pvs_video` is the path to the input **distorted** MP4 video
- 2nd positional argument: `ref_video` is the path to the input **reference** MP4 video
- 3rd positional argument: `result_file` is the path to the location on the disk to write your result file



### Result file format

After taking input videos, your model should output a single result file to the location specified by command line option `resulf_file`. You do NOT need to add `txt` extension to the path given by the command line. Full output file path will be given by the command line input.

The result file is **a txt file with only one float point number ranging from 0 to 100 in a single line**. The number should represent your model's prediction of the input video quality. 



### Our testing procedures

In our testing pipeline, we will build your docker image first by running a shell script your prepared. The script is named `docker_build.sh` and should be placed in the root folder of your code. If no extra building requirement, the script should look like below

```shell
#!/bin/sh
docker build --tag vqm-test .
```

You can modify the build script if you need to customized building steps beyond the Dockerfile.



During evaluation process, you can use the `/data/tmp` inside docker as a location to store local file. For example, if you need to decode the input video into Y4M or image, you can store the file at this location. An external disk will be mounted on the docker at `/data` to store the input file and output result.

The following commands will be run to get your model's output for one video:

For NR model:

```bash
docker run --rm --gpus all -v [local_storage_folder]:/data -t vqm-test [input-distorted-video-path] [output_result_file_path]
```

For FR model:

```bash
docker run --rm --gpus all -v [local_storage_folder]:/data -t vqm-test [input-distorted-video-path] [input-reference-video-path] [output_result_file_path]
```