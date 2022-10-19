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



## Docker submission guideline

### Python

For python application, the Dockerfile ENTRYPOINT should be your interpreter plus your scripts/module. For example, 

```dockerfile
ENTRYPOINT ["python3","./your_script.py"]
# or
ENTRYPOINT ["python3","-m","your_module"]
```

Within `your_script.py` or `your_module` `__main__.py` file, you can use `argparse` package or directly reading `sys.argv` to get the input video path as defined in section [Docker command line interface](##Docker command line interface). 



An example python environment setup with some pre-installed packages is given in this repo, if you need a template to start.



### C/C++

For C/C++ application, you should build your application into binary executable console application in  Dockerfile and set the ENTRYPOINT to your application so that command line parameters can be passed into your program through docker run command.





### Docker command line interface

Please following the command line interface below:

For no reference (NR) model:

`--pvs_video` is the path to the input **distorted** MP4 video

`--result_file` is the path to the location on the disk to write your result file



For full reference (FR) model:

`--pvs_video` is the path to the input **distorted** MP4 video

`--ref_video` is the path to the input **reference** MP4 video

`--result_file` is the path to the location on the disk to write your result file



### Result file format

After taking input videos, your model should output a single result file to the location specified by command line option `--resulf_file`. You do NOT need to add `txt` extension to the path given by the command line. Full output file path will be given by the command line input.

The result file is **a txt file with only one float point number ranging from 0 to 100 in a single line**. The number should represent your model's prediction of the input video quality. 



### GPU model

To be added



### Our testing procedures

In our testing pipeline, we will build your docker image first by running a shell script your prepared. The script is named `docker_build.sh` and should be placed in the root folder of your code. If no extra building requirement, the script should look like below

```shell
#!/bin/sh
docker build --tag vqm-test .
```

You can modify the build script if you need to customized building steps beyond the Dockerfile.



During evaluation process, the following commands will be run to get your model's output for one video:

For NR model:

```bash
docker run --rm -t vqm-test --pvs_video [input-distorted-video-path] --result_file [output_result_file_path]
```

For FR model:

```bash
docker run --rm -t vqm-test --pvs_video [input-distorted-video-path] --ref_video [input-reference-video-path] --result_file [output_result_file_path]
```