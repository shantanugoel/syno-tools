#!/bin/bash

mkv_processed=0
ass_extracted=0
srt_converted=0

# Check Dependencies
check_missing_deps() {
    #hash mkvmerge 2>/dev/null || { echo >&2 "Install missing dependency mkvmerge"; return 0; }
    hash ffmpeg 2>/dev/null || { echo >&2 "Install missing dependency ffmpeg"; return 0; }
    return 1
}

usage() {
    echo "Usage: $0 <mkv_dir_or_file>"
}

convert_srt() {
    echo Converting to srt for $1
    ((srt_converted++))
}

extract_ass() {
    echo Extracting ass for $1
    mkv_file_base=$(basename -s .mkv $1)
    ass_file_name=${mkv_file_base}.ass
    ((ass_extracted++))
    convert_srt $ass_file_name
}

ass2srt() {
    mkv_file_name=$1
    mkv_file_dir=$(dirname $mkv_file_name)
    cd $mkv_file_dir
    ((mkv_processed++))
    extract_ass $mkv_file_name
    cd -
}

ass2srtdir() {
    cd $1
    shopt -s globstar
    for mkv in {,**/}*.mkv
    do
        ass2srt $mkv
    done
    cd -
}

main() {
    if [ "$#" -ne 1 ]; then
        usage
        exit 1
    fi

    if check_missing_deps; then
        exit 1
    fi

    if [ -f $1 ]; then
        ass2srt $1
    elif [ -d $1 ]; then
        ass2srtdir $1
    else
        echo "Invalid argument. Not a file or dir"
        exit 1
    fi

    echo Processed $mkv_processed mkv files. Extracted $ass_extracted ass subs. Converted $srt_converted srt subs.
}

main $@
