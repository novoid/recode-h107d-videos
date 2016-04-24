#!/bin/sh

## This script takes a number of video files as input set and
## recodes them to 720x480 using libxvid.
## This way, Hubsan h107d-videos are being recoded to smaller
## size and fixed aspect ratio.

## License: GPL v3 or higher
## Author: Karl Voit
## https://github.com/novoid/recode-h107d-videos

while getopts ":v" OPTION; do
        case "$OPTION" in
                v)      VERBOSE="YES" ;;
                *)      echo "Usage $0 [file [file ...]]" && exit 1 ;;
        esac
done

recode_video_file()
{
    ffmpeg -i "${1}" -f avi -r 29.97 -vcodec libxvid \
		    -vtag XVID -vf scale=720:480 ${3}\
		    -aspect 4:3 -maxrate 1800k -b 1500k \
		    -qmin 3 -qmax 5 -bufsize 4096 \
		    -mbd 2 -bf 2 -trellis 1 -flags +aic \
		    -cmp 2 -subcmp 2 -g 300 "${2}"
    if [ $? -ne 0 ]; then
        echo "Converting of \"${1}\" to \"${2}\" went wrong. Aborted."
        exit 20
    fi
}

[ -z "$VERBOSE" ] && loglevel='-loglevel quiet' || loglevel=''

for myfile in "$@"; do
    if ! [ -f "${myfile}" ]; then
        echo "File ${myfile} is not found"
        continue
    fi

    originalFile="${myfile/\.*/.${myfile##*.}.original}"
    resultFile="${myfile/\.*/.${myfile##*.}.converted}"

    echo "${myfile}  --- mv -------->  ${originalFile}"
    mv "${myfile}" "${originalFile}"

    echo "${myfile}  --- convert --->  ${resultFile}"
    recode_video_file "${originalFile}" "${resultFile}" "${loglevel}" &&
    rm "${originalFile}"
done
