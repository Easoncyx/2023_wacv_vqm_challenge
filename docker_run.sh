#!/bin/sh
video_folder="$1"
pvs_video="$2"
ref_video="$3"
report_folder="$4"
result_file="$5"
tmp_folder="$6"

echo $video_folder
echo $pvs_video
echo $ref_video
echo $report_folder
echo $result_file
echo $tmp_folder

docker run --rm --gpus all -v ${video_folder}:/data/videos \
    -v ${report_folder}:/data/reports \
    -v ${tmp_folder}:/data/tmp \
    -t vqm-test \
    /data/videos/${pvs_video} \
    /data/videos/${ref_video} \
    /data/reports/${result_file}