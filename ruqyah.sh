#!/bin/bash
set -u

BASE_URL="https://everyayah.com/data/Ghamadi_40kbps"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ruqyah.XXXXXX")"
ORIGINAL_VOLUME=""
ORIGINAL_MUTED=""
PLAYER_PID=""

restore_volume() {
  if [[ -n "$PLAYER_PID" ]] && kill -0 "$PLAYER_PID" 2>/dev/null; then
    kill "$PLAYER_PID" 2>/dev/null || true
    wait "$PLAYER_PID" 2>/dev/null || true
  fi
  if [[ "$ORIGINAL_VOLUME" =~ ^[0-9]+$ ]]; then
    osascript -e "set volume output volume $ORIGINAL_VOLUME" >/dev/null 2>&1 || true
  fi
  if [[ "$ORIGINAL_MUTED" == "true" || "$ORIGINAL_MUTED" == "false" ]]; then
    osascript -e "set volume output muted $ORIGINAL_MUTED" >/dev/null 2>&1 || true
  fi
  rm -rf "$TMP_DIR"
}
trap restore_volume EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Senarai ayat boleh diubah di sini.
RANGES=(
  "1:1-7"
  "2:1-5"
  "2:102-102"
  "2:163-164"
  "2:255-255"
  "2:285-286"
  "3:18-19"
  "7:117-122"
  "10:81-82"
  "20:69-69"
  "23:115-118"
  "37:1-10"
  "59:21-24"
  "112:1-4"
  "113:1-5"
  "114:1-6"
)

if ! command -v osascript >/dev/null || ! command -v afplay >/dev/null; then
  echo "Ralat: osascript atau afplay tidak ditemui."
  exit 1
fi

ORIGINAL_VOLUME="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null || true)"
ORIGINAL_MUTED="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null || true)"
if [[ ! "$ORIGINAL_VOLUME" =~ ^[0-9]+$ || ( "$ORIGINAL_MUTED" != "true" && "$ORIGINAL_MUTED" != "false" ) ]]; then
  echo "Ralat: tidak dapat membaca volume asal. Ruqyah dibatalkan."
  exit 1
fi

echo "[$(date)] Ruqyah bermula."
echo "Volume dikunci pada 30% sepanjang bacaan."

for range in "${RANGES[@]}"; do
  surah="${range%%:*}"
  verses="${range#*:}"
  first="${verses%-*}"
  last="${verses#*-}"

  for ((ayah=10#$first; ayah<=10#$last; ayah++)); do
    file="$(printf '%03d%03d.mp3' "$((10#$surah))" "$ayah")"
    audio="$TMP_DIR/$file"
    url="$BASE_URL/$file"

    echo "Memainkan $file"
    if curl --fail --location --silent --show-error --retry 2 --connect-timeout 20 "$url" -o "$audio"; then
      if [[ -s "$audio" ]]; then
        osascript -e 'set volume output volume 30 output muted false' >/dev/null
        afplay "$audio" &
        PLAYER_PID=$!
        while kill -0 "$PLAYER_PID" 2>/dev/null; do
          osascript -e 'set volume output volume 30' >/dev/null 2>&1 || true
          sleep 0.2
        done
        wait "$PLAYER_PID" || echo "Amaran: audio $file tidak dapat dimainkan."
        PLAYER_PID=""
      else
        echo "Amaran: audio kosong ($file)."
      fi
      rm -f "$audio"
    else
      echo "Amaran: gagal mendapatkan $file; melangkau ayat ini."
      rm -f "$audio"
    fi
  done
done

echo "[$(date)] Ruqyah selesai. Volume asal akan dipulihkan."
