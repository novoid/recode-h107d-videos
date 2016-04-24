#!/bin/sh

## This script takes a number of video files as input set and
## recodes them to 720x480 using libxvid.
## This way, Hubsan h107d-videos are being recoded to smaller
## size and fixed aspect ratio.

## License: GPL v3 or higher
## Author: Karl Voit
## https://github.com/novoid/recode-h107d-videos

errorexit()
{
    [ "$1" -lt 1 ] && echo "$FILENAME done."
    if [ "$1" -gt 0 ]; then
        echo
        echo "$FILENAME aborted with errorcode $1:  $2"
        echo
    fi  

    exit $1
}

recode_video_file()
{
    ffmpeg -i "${1}" -f avi -r 29.97 -vcodec libxvid \
		    -vtag XVID -vf scale=720:480 \
		    -aspect 4:3 -maxrate 1800k -b 1500k \
		    -qmin 3 -qmax 5 -bufsize 4096 \
		    -mbd 2 -bf 2 -trellis 1 -flags +aic \
		    -cmp 2 -subcmp 2 -g 300 "${2}" || \
    errorexit 20 "recoding of \"${1}\" to \"${1}\" went wrong. Aborted."
}

for myfile in "$@"; do
    
    filebasename=`basename "${myfile}"`

    test "${filebasename}" = "${myfile}" || \
    errorexit 1 "this script only supports file names without folders"

    [ -f "${filebasename}" ] || \
    errorexit 2 "file \"${filebasename}\" not an existing file."

    newinputfilename=`echo "${filebasename}" | sed 's/\(\....\)$/ -- h107d original\1/'`
    resultfilename=`echo "${filebasename}" | sed 's/\(\....\)$/ -- h107d recoded\1/'`

    echo "${filebasename}  --- mv -------->  ${newinputfilename}"
    mv "${filebasename}" "${newinputfilename}"
    echo "${filebasename}  --- convert --->  ${resultfilename}"
    
    recode_video_file "${newinputfilename}" "${resultfilename}"
    rm "${newinputfilename}"
    
done
