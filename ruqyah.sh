#!/bin/bash
set -u

BASE_URL="https://everyayah.com/data/Ghamadi_40kbps"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ruqyah.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

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

echo "[$(date)] Ruqyah bermula."

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
        afplay "$audio" || echo "Amaran: audio $file tidak dapat dimainkan."
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

echo "[$(date)] Ruqyah selesai."
