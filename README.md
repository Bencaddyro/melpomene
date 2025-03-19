## Install

Install on firefox:
```
about:debugging#/runtime/this-firefox -> load temporary addon -> addon/manifest.json
```

Allow native messaging
```bash
ln app/melpomene.json ~/.mozilla/native-messaging-hosts/melpomene.json
```

Create service
```bash
cp melpomene.service /etc/systemd/system/melpomene.service
systemctl enable --now melpomene.service
```

Compile rust app
```bash
cargo build --release
```

Also need `yt-dlp` & `python3` & `rust`

**You will need to modify source code as path are hard coded (look for /bencaddyro)** #BadPractice

## Files tree:

```
larsen/melpomene/ #Output of files
|-info/
|-thumbnail/
|-archive
|-clip/
|-clean/
|-dirty/

skaffen/melpomene/ #Code & socket
|-src/
|-target/
|-addon/
| |-manifest.json
| |-background.js
|-sock
|-legacy
```

## How it work

Extension call python script that send message to socket to a rust app that will call yt-dlp  
It then apply post process to sort and fixes output file to various folder
Work with youtube & youtube music, probably other yt-dlp compatible website
