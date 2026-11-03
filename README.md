# Ruqyah

Pemain audio Ruqyah untuk **macOS dan Windows** menggunakan bacaan Syeikh Saad Al-Ghamdi daripada EveryAyah.

## Fungsi
- Satu projek dan senarai ayat untuk kedua-dua sistem operasi.
- Main secara automatik apabila pengguna log masuk.
- Main setiap hari pada jam 2:00 petang mengikut waktu tempatan komputer.
- Memainkan audio ayat demi ayat.
- MP3 dimuat turun sementara dan dipadam selepas dimainkan.
- Perlu sambungan internet dan pengguna mesti log masuk.

## Pemasangan macOS

Buka Terminal dan jalankan:

```bash
curl -fsSL https://raw.githubusercontent.com/fahmieabdrahim/ruqyah/main/install.sh | bash
```

## Pemasangan Windows 10/11

**Pilihan A — PowerShell**

Buka Windows PowerShell dan jalankan:

```powershell
irm https://raw.githubusercontent.com/fahmieabdrahim/ruqyah/main/install.ps1 | iex
```

**Pilihan B — Command Prompt (CMD)**

Buka CMD dan jalankan arahan ini:

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm 'https://raw.githubusercontent.com/fahmieabdrahim/ruqyah/main/install.ps1' | iex"
```

Kedua-dua pilihan memasang perkara yang sama. Selepas pemasangan, tetingkap CMD atau PowerShell boleh ditutup. Pemain berjalan secara tersembunyi.

## Cara mematikan auto-play

Arahan ini menghentikan jadual automatik tetapi tidak membuang fail pemasangan.

### macOS

Buka Terminal:

```bash
launchctl bootout "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.fahmie.ruqyah.plist"
```

Untuk aktifkan semula:

```bash
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.fahmie.ruqyah.plist"
```

### Windows

Buka PowerShell atau CMD (arahan ini boleh dijalankan dari kedua-duanya):

**Matikan auto-play:**

```cmd
powershell -NoProfile -Command "Disable-ScheduledTask -TaskName 'Ruqyah-Logon','Ruqyah-Daily-1400'"
```

**Aktifkan semula auto-play:**

```cmd
powershell -NoProfile -Command "Enable-ScheduledTask -TaskName 'Ruqyah-Logon','Ruqyah-Daily-1400'"
```

## Nyahpasang sepenuhnya

### macOS

```bash
launchctl bootout "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.fahmie.ruqyah.plist" 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/com.fahmie.ruqyah.plist"
rm -rf "$HOME/.local/share/ruqyah"
```

### Windows

Jalankan dalam PowerShell atau CMD:

```cmd
powershell -NoProfile -Command "Unregister-ScheduledTask -TaskName 'Ruqyah-Logon' -Confirm:\$false -ErrorAction SilentlyContinue; Unregister-ScheduledTask -TaskName 'Ruqyah-Daily-1400' -Confirm:\$false -ErrorAction SilentlyContinue; Remove-Item '\$env:LOCALAPPDATA\Ruqyah' -Recurse -Force"
```

## Nota penting
- Komputer perlu hidup, tidak berada dalam Sleep, dan pengguna perlu log masuk pada waktu jadual untuk audio dimainkan.
- Jika komputer dimatikan atau tidur pada 2:00 petang, main semula tidak dijamin tepat pada waktunya.
- Audio distrim satu ayat pada satu masa; fail sementara dipadam selepas dimainkan.
- Senarai ayat ditetapkan dalam `ruqyah.sh` dan `ruqyah.ps1`.

## Sumber audio
EveryAyah — Saad Al-Ghamdi, folder `Ghamadi_40kbps`. Sila semak syarat penggunaan dan atribusi sumber sebelum pengedaran semula.
