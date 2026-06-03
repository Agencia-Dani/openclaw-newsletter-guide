#!/bin/bash
VOICE_DIR="/Users/estefanybenavides/Downloads/Telegram Desktop/ChatExport_2026-06-03 (1)/voice_messages"
OUT_DIR="/Users/estefanybenavides/Documents/Claude/workspace/openclaw-guide/transcripts"

cd "$VOICE_DIR"

files=$(ls audio_*.ogg | awk -F'[_@]' '{print $2"\t"$0}' | sort -n | cut -f2)

for f in $files; do
  basename="${f%.ogg}"
  out_file="$OUT_DIR/${basename}.txt"

  if [ -f "$out_file" ] && [ -s "$out_file" ]; then
    echo "SKIP $basename"
    continue
  fi

  echo "TRANSCRIBE $basename"
  json=$(trx transcribe "$VOICE_DIR/$f" --fields text --output-dir /tmp -l es -o json 2>/dev/null)
  text=$(echo "$json" | python3 -c "import sys, json; print(json.load(sys.stdin).get('text',''))" 2>/dev/null)
  if [ -n "$text" ]; then
    echo "$text" > "$out_file"
  else
    echo "[FAILED]" > "$out_file"
  fi
done

echo "DONE: $(ls "$OUT_DIR"/audio_*.txt 2>/dev/null | wc -l) files transcribed"
