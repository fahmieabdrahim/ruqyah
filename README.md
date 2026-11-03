# Ruqyah

Pemain audio Ruqyah untuk macOS menggunakan bacaan Syeikh Saad Al-Ghamdi daripada EveryAyah.

## Fungsi
- Main secara automatik apabila pengguna log masuk ke Mac.
- Main setiap hari pada jam 2:00 petang mengikut waktu tempatan Mac.
- Memainkan audio ayat demi ayat.
- Fail MP3 dimuat turun sementara ke folder sementara sistem dan dipadam selepas dimainkan.
- Tidak memerlukan aplikasi pihak ketiga; menggunakan `curl`, `afplay` dan LaunchAgent macOS.

## Pemasangan

```bash
curl -fsSL https://raw.githubusercontent.com/fahmieabdrahim/ruqyah/main/install.sh | bash
```

Pemasangan memerlukan sambungan internet. Mac perlu hidup dan pengguna perlu log masuk untuk main automatik.

## Sumber audio
EveryAyah — Saad Al-Ghamdi, folder `Ghamadi_40kbps`.
Audio dibekalkan sebagai fail berasingan bagi setiap ayat. Sila semak syarat penggunaan dan atribusi sumber sebelum pengedaran semula.

## Nyahpasang

```bash
launchctl bootout "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.fahmie.ruqyah.plist" 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/com.fahmie.ruqyah.plist"
rm -rf "$HOME/.local/share/ruqyah"
```
