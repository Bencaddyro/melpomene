
pub fn default_param() -> Vec<&'static str> { vec![
// General behaviour
"--ignore-errors", // Ignore download and postprocessing errors. The download will be considered successful even if the postprocessing fails
"--continue", // Resume partially downloaded files/fragments (default)
//"--download-archive", "/home/bencaddyro/larsen/melpomene/archive_dev", // Download only videos not listed in the archive file. Record the IDs of all downloaded videos in it
"--geo-bypass", // How to fake X-Forwarded-For HTTP header to try bypassing geographic restriction.

// Metadata
"--write-info-json", // Write video metadata to a .info.json file (this may contain personal information)
"--no-write-playlist-metafiles", // Do not write playlist metadata when using --write-info-json, --write-description etc.
"--embed-metada", // Embed metadata to the video file. Also embeds chapters/infojson if present unless --no-embed-chapters/--no-embed-info-json are used
"--no-embed-info-json",
"--no-embed-chapters",

// Logs
"--no-progress", // Do not print progress bar
"--no-colors",

// Video behaviour
"--write-all-thumbnails", // Write all thumbnail image formats to disk
"--sleep-interval", "1", // Number of seconds to sleep before each download.
"--yes-playlist", // Download the playlist, if the URL refers to a video and a playlist

// Location
"--paths", "home:/home/bencaddyro/larsen/melpomene",
"--paths", "temp:/home/bencaddyro/larsen/melpomene/temp",
"--paths", "thumbnail:thumbnail",
"--output", "thumbnail:%(id)s/%(id)s-%(epoch>%Y-%m-%d_%H-%M-%S)s-%(title)s",
"--paths", "infojson:infojson",
"--output", "infojson:%(id)s-%(epoch>%Y-%m-%d_%H-%M-%S)s-%(title)s",
//"--output", "%(ext)s/%(playlist_index)s-%(title)s-%(id)s-%(playlist_id)s.%(ext)s",

// Post process
//"--extract-audio", // Convert video files to audio-only files (requires ffmpeg and ffprobe)
//"--audio-format", "opus", // Format to convert the audio to when -x is used.
"--embed-thumbnail", // Embed thumbnail in the video as cover art
"--merge-output", "mkv", // Containers that may be used when merging formats, separated by "/", e.g. "mp4/mkv". Ignored if no merge is required.
]}