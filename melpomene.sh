#!/bin/bash

# Function to log to journald
log_to_journal() {
    echo "$1" | systemd-cat -t melpomene
}

# Cleanup function to delete files by basename
cleanup_files() {
    for name in "$@"; do
        find "/home/bencaddyro/larsen/melpomene" -name "$(basename "$name")" -delete
    done
}

# Delete URL from archive files
delete_from_archives() {
    local url="$1"

    # Extract video ID from URL using yt-dlp
    local video_id=$(yt-dlp --get-id "$url" 2>/dev/null)

    if [ -n "$video_id" ]; then
        local msg="Deleting $video_id from archives for URL: $url"
        echo "$msg" >&2
        log_to_journal "$msg"

        # Remove from both archive files
        if [ -f "/home/bencaddyro/larsen/melpomene/archive_audio" ]; then
            sed -i "/youtube $video_id$/d" "/home/bencaddyro/larsen/melpomene/archive_audio"
        fi

        if [ -f "/home/bencaddyro/larsen/melpomene/archive_clip" ]; then
            sed -i "/youtube $video_id$/d" "/home/bencaddyro/larsen/melpomene/archive_clip"
        fi

        local done_msg="Deleted $video_id from archives"
        echo "$done_msg" >&2
        log_to_journal "$done_msg"
    else
        local err_msg="Could not extract video ID from URL: $url"
        echo "$err_msg" >&2
        log_to_journal "$err_msg"
    fi
}

# Check if URL exists in archive files
check_archives() {
    local url="$1"

    # Extract video ID from URL using yt-dlp
    local video_id=$(yt-dlp --get-id "$url" 2>/dev/null)

    if [ -n "$video_id" ]; then
        local in_audio=false
        local in_clip=false

        # Check audio archive
        if [ -f "/home/bencaddyro/larsen/melpomene/archive_audio" ] && grep -q "youtube $video_id$" "/home/bencaddyro/larsen/melpomene/archive_audio"; then
            in_audio=true
        fi

        # Check clip archive
        if [ -f "/home/bencaddyro/larsen/melpomene/archive_clip" ] && grep -q "youtube $video_id$" "/home/bencaddyro/larsen/melpomene/archive_clip"; then
            in_clip=true
        fi

        # Return status as JSON
        local status=""
        if [ "$in_audio" = true ] && [ "$in_clip" = true ]; then
            status="In audio & clip archives"
        elif [ "$in_audio" = true ]; then
            status="In audio archive"
        elif [ "$in_clip" = true ]; then
            status="In clip archive"
        else
            status="Not in archives"
        fi

        echo "{\"video_id\":\"$video_id\",\"status\":\"$status\",\"in_audio\":$in_audio,\"in_clip\":$in_clip}"
    else
        echo "{\"error\":\"Could not extract video ID\"}"
    fi
}

# Read message length (4 bytes) and message from stdin
read_message() {
    # Read 4-byte length header
    length_bytes=$(dd bs=4 count=1 2>/dev/null | od -An -tx1 | tr -d ' ')
    if [ -z "$length_bytes" ]; then
        exit 0
    fi
    
    # Convert hex to decimal (little-endian)
    length=$((16#${length_bytes:6:2}${length_bytes:4:2}${length_bytes:2:2}${length_bytes:0:2}))
    
    # Read message of specified length
    message=$(dd bs=$length count=1 2>/dev/null)
    echo "$message"
}

# Send message to stdout with length header
send_message() {
    local message="$1"
    local length=${#message}

    # Convert length to 4-byte little-endian using printf with hex
    printf "\\x$(printf %02x $((length & 255)))"
    printf "\\x$(printf %02x $(((length >> 8) & 255)))"
    printf "\\x$(printf %02x $(((length >> 16) & 255)))"
    printf "\\x$(printf %02x $(((length >> 24) & 255)))"
    printf "%s" "$message"
}

# Default yt-dlp parameters
get_default_params() {
    echo "--ignore-errors \
--continue \
--geo-bypass \
--write-info-json \
--no-write-playlist-metafiles \
--embed-metadata \
--no-embed-info-json \
--no-embed-chapters \
--no-progress \
--no-colors \
--write-all-thumbnails \
--sleep-interval 1 \
--yes-playlist \
--paths home:/home/bencaddyro/larsen/melpomene \
--paths temp:/home/bencaddyro/larsen/melpomene/temp \
--paths thumbnail:thumbnail \
--output thumbnail:%(id)s/%(id)s-%(epoch>%Y-%m-%d_%H-%M-%S)s-%(title)s \
--paths infojson:infojson \
--output infojson:%(id)s-%(epoch>%Y-%m-%d_%H-%M-%S)s-%(title)s \
--embed-thumbnail \
--merge-output mkv"
}

# Download functions
download_clip() {
    local url="$1"
    local extract_audio="$2"
    
    local msg="Processing clip $url | extract: $extract_audio"
    echo "$msg" >&2
    log_to_journal "$msg"
    
    local params="$(get_default_params)"
    
    if [ "$extract_audio" = "true" ]; then
        params="$params --extract-audio --audio-format opus --keep-video"
    fi
    
    params="$params --output clip/%(playlist_index)s-%(title)s-%(id)s-%(playlist_id)s.%(ext)s"
    params="$params --download-archive /home/bencaddyro/larsen/melpomene/archive_clip"
    
    local output=$(yt-dlp $params "$url" 2>&1)
    echo "$output" >&2
    log_to_journal "$output"
    
    # Run cleanup if audio extraction was requested
    if [ "$extract_audio" = "true" ]; then
        # Extract downloaded filenames from yt-dlp output and cleanup
        echo "$output" | grep -o '\[download\] [^:]*: Destination: [^"]*' | sed 's/.*Destination: //' | while read -r filename; do
            if [ -n "$filename" ]; then
                cleanup_files "$filename"
            fi
        done
    fi
    
    local done_msg="Done clip $url"
    echo "$done_msg" >&2
    log_to_journal "$done_msg"
}

download_audio() {
    local url="$1"
    local clean_audio="$2"
    
    local msg="Processing audio $url | clean: $clean_audio"
    echo "$msg" >&2
    log_to_journal "$msg"
    
    local params="$(get_default_params)"
    params="$params --extract-audio --audio-format opus"
    params="$params --download-archive /home/bencaddyro/larsen/melpomene/archive_audio"
    
    if [ "$clean_audio" = "true" ]; then
        params="$params --output clean/%(playlist_index)s-%(title)s-%(id)s-%(playlist_id)s.%(ext)s"
    else
        params="$params --output dirty/%(playlist_index)s-%(title)s-%(id)s-%(playlist_id)s.%(ext)s"
    fi
    
    local output=$(yt-dlp $params "$url" 2>&1)
    echo "$output" >&2
    log_to_journal "$output"
    
    local done_msg="Done audio $url"
    echo "$done_msg" >&2
    log_to_journal "$done_msg"
}

# Main loop
while true; do
    message=$(read_message)
    if [ -z "$message" ]; then
        logger -t "melpomene"  -p user.err "Empty message"
        exit 0
    fi
    
    # Parse JSON message to extract the actual message content
    content=$(echo "$message" | sed -n 's/.*"\([^"]*\)".*/\1/p')

    logger -t "melpomene" "Receive: $content"

    # Split option and URL
    option=$(echo "$content" | cut -d';' -f1)
    url=$(echo "$content" | cut -d';' -f2-)
    
    send_message "{\"status\":\"ACK\",\"message\":\"$content\"}"
    
    case "$option" in
        "clip")
            download_clip "$url" "false"
            ;;
        "clip+audio")
            download_clip "$url" "true"
            ;;
        "audio_clean")
            download_audio "$url" "true"
            ;;
        "audio_dirty")
            download_audio "$url" "false"
            ;;
        "delete")
            delete_from_archives "$url"
            ;;
        "check_status")
            result=$(check_archives "$url")
            send_message "{\"status\":\"STATUS\",\"data\":$result}"
            ;;
        *)
            local err_msg="Option $option not supported, abort $url"
            echo "$err_msg" >&2
            log_to_journal "$err_msg"
            ;;
    esac
    
    send_message "{\"status\":\"DONE\",\"message\":\"$content\"}"
done
