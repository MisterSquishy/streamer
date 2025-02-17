#!/bin/sh

OUTPUT_PATH=/tmp/stream/

DEFAULT_VIDEO="copy"
IS_RTSP=""

INPUT=$1
OUTPUT=$2

# Check if codecs are already in the format supported by Chromecast devices (aac for audio and h264 for video)
AUDIO_RESULT="$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name   -of default=noprint_wrappers=1:nokey=1 $INPUT)"
VIDEO_RESULT="$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name   -of default=noprint_wrappers=1:nokey=1 $INPUT)"

if [ "$VIDEO_RESULT" != "h264" ]; then
  DEFAULT_VIDEO=h264
fi

if [ "$INPUT" == rtsp://* ]; then
  IS_RTSP="-rtsp_transport tcp"
fi

FFMPEG_CMD="ffmpeg ${IS_RTSP} -i ${INPUT} -f lavfi -i aevalsrc=0 -vcodec ${DEFAULT_VIDEO} -hls_list_size 50 -hls_init_time 1 -hls_time 1 -hls_flags delete_segments ${OUTPUT_PATH}${OUTPUT}.m3u8"

until ${FFMPEG_CMD} ; do
  echo "restarting ffmpeg command..."
  sleep 2
done
