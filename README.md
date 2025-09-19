# 🎭 Melpomene 


## Requirements

- `yt-dlp`
- `ffmpg`

## Install

1. Allow native messaging
```bash
ln app/melpomene.json ~/.mozilla/native-messaging-hosts/melpomene.json
```

2. Install extension on browser:

- From Release xpi:
`about:addons` -> `Extensions` -> `⚙️` -> `Install from file` (or you can also drag'n'drop file to firefox window)

- From source as temporary extension
```
about:debugging#/runtime/this-firefox -> load temporary addon -> manifest.json
```

3. Download source code + Search & Replace hardcoded path: 

Git clone this repository and replace

- `/home/bencaddyro/larsen/melpomene` for targer directory (where files will be downloaded)
- `/home/bencaddyro/skaffen/melpomene` for this code repository (where to find `melpomene.sh`)

## Debug

Follow logs with

```bash
journalctl -t melpomene -f
```

## Futur

- Automate old downloaded file
- Fail safe & cleanup for tmp file leftover
- Continue automation stream with `picard`
