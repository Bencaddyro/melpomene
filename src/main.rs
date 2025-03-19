
use std::thread;
use std::os::unix::net::{UnixStream, UnixListener};
use std::path::Path;
use std::fs;
use std::io::Read;

use std::process::Command;

use crate::options::default_param;

mod options;


fn handle_client(mut stream: UnixStream) {
    let mut buffer = String::new();
    stream.read_to_string(&mut buffer).unwrap();
    let v : Vec<&str> = buffer.split(';').collect();
    let option = v[0];
    let url = v[1];

    match option {
        "clip" => download_clip(url, false),
        "clip+audio" => download_clip(url, true),
        "audio_clean" => download_audio(url, true),
        "audio_dirty" => download_audio(url, false),
        _ => println!("Option {option} not supported, abort {url}"),
    };
}


fn download_audio(url: &str, clean_audio: bool) {

    println!("Processing audio {url} | clean: {clean_audio}");
    // Basic arg
    let mut arguments = default_param();
    // Audio arg
    arguments.append(vec![
        "--extract-audio", // Convert video files to audio-only files (requires ffmpeg and ffprobe)
        "--audio-format", "opus", // Format to convert the audio to when -x is used.
        "--download-archive", "/home/bencaddyro/larsen/melpomene/archive_audio", // Download only videos not listed in the archive file. Record the IDs of all downloaded videos in it
        ].as_mut()
    );
    if clean_audio { arguments.append(vec!["--output", "clean/%(playlist_index)s-%(title)s-%(id)s-%(playlist_id)s.%(ext)s"].as_mut())}
    else { arguments.append(vec!["--output", "dirty/%(playlist_index)s-%(title)s-%(id)s-%(playlist_id)s.%(ext)s"].as_mut())};

    let child = Command::new("yt-dlp").args(&arguments).arg(url).output().unwrap();
    println!("Done audio {url}\n{}\n{}\n{}\n", child.status, String::from_utf8(child.stdout).unwrap(), String::from_utf8(child.stderr).unwrap());

}

fn download_clip(url: &str, extract_audio: bool) {

    println!("Processing clip {url} | extrat: {extract_audio}");
    // Basic arg
    let mut arguments = default_param();
    // Audio arg
    if extract_audio {
        arguments.append(vec![
        "--extract-audio", // Convert video files to audio-only files (requires ffmpeg and ffprobe)
        "--audio-format", "opus", // Format to convert the audio to when -x is used.
        "--keep-video", // Keep the intermediate video file on disk after post‐processing    
        "--exec", "/home/bencaddyro/skaffen/melpomene/cleanup.sh %(requested_formats.:.filepath)#q", // Remove video wihtout audio
        ].as_mut()
    )};
    arguments.append(vec![
        "--output", "clip/%(playlist_index)s-%(title)s-%(id)s-%(playlist_id)s.%(ext)s",
        "--download-archive", "/home/bencaddyro/larsen/melpomene/archive_clip", // Download only videos not listed in the archive file. Record the IDs of all downloaded videos in it
        ].as_mut()); 

    let child = Command::new("yt-dlp").args(&arguments).arg(url).output().unwrap();
    println!("Done clip {url}\n{}\n{}\n{}\n", child.status, String::from_utf8(child.stdout).unwrap(), String::from_utf8(child.stderr).unwrap());

}


fn main() {

    let socket = "/home/bencaddyro/skaffen/melpomene/sock";

    if Path::new(socket).exists() {
         fs::remove_file(socket).unwrap();
    }

    let listener = UnixListener::bind(socket).unwrap();

    // accept connections and process them, spawning a new thread for each one
    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                /* connection succeeded */
                println!("New connexion !");
                thread::spawn(|| handle_client(stream));
            }
            Err(err) => {
                println!("{err}");
                /* connection failed */
                break;
            }
        }
    };
}

