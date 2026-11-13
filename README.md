# Ruqyah

Pemain audio Ruqyah untuk **macOS dan Windows** menggunakan bacaan Syeikh Saad Al-Ghamdi daripada EveryAyah.

## Fungsi
- Satu projek dan senarai ayat untuk kedua-dua sistem operasi.
- Main secara automatik apabila pengguna log masuk.
- Main setiap hari pada jam 2:00 petang mengikut waktu tempatan komputer.
- Memainkan audio ayat demi ayat.
- Volume output ditetapkan pada 30% dan mute dinyahaktifkan semasa setiap ayat dimainkan.
- Volume dan status mute asal dipulihkan selepas keseluruhan sesi tamat atau dihentikan.
- Perubahan volume semasa playback dikesan dan dikembalikan kepada 30%.

- MP3 dimuat turun sementara dan dipadam selepas dimainkan.
- Perlu sambungan internet dan pengguna mesti log masuk.

## Kawalan volume

Semasa bacaan berlangsung, Ruqyah menetapkan volume output sistem pada 30% dan menguatkuasakan semula tetapan itu secara berkala. Selepas sesi playback tamat atau dihentikan, volume asal dipulihkan dan kawalan volume kembali normal.

**Nota:** Kawalan volume fizikal pada papan kekunci, alat kawalan headset atau peranti audio mungkin masih memberi kesan seketika sebelum tetapan 30% dikuatkuasakan semula. Fungsi ini mengawal volume output lalai sistem.

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

Buka CMD dan jalankan:

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm 'https://raw.githubusercontent.com/fahmieabdrahim/ruqyah/main/install.ps1' | iex"
```

Kedua-dua pilihan memasang perkara yang sama. Selepas pemasangan, tetingkap CMD atau PowerShell boleh ditutup. Pemain berjalan secara tersembunyi.

---

## Kawalan Ruqyah

Arahan di bawah hanya untuk menghentikan bacaan atau membuang aplikasi sepenuhnya.

### Windows — PowerShell

**STOP — hentikan bacaan yang sedang dimainkan:**

```powershell
$playerPath = Join-Path $env:LOCALAPPDATA "Ruqyah\ruqyah.ps1"
Get-CimInstance Win32_Process -Filter "name='powershell.exe'" |
Where-Object { $_.CommandLine -like "*-File *$playerPath*" } |
ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
```

### Windows — CMD

**STOP:**

```cmd
powershell -NoProfile -Command "$p=Join-Path $env:LOCALAPPDATA 'Ruqyah\ruqyah.ps1'; Get-CimInstance Win32_Process -Filter \"name='powershell.exe'\" | Where-Object { $_.CommandLine -like ('*-File *' + $p + '*') } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }"
```

### macOS — Terminal

**STOP — hentikan bacaan yang sedang berjalan:**

```bash
launchctl kill SIGTERM "gui/$(id -u)/com.fahmie.ruqyah"
```

---

## Nyahpasang semua (Uninstall All)

Arahan ini menghentikan pemain, membuang jadual automatik dan memadam fail aplikasi.

### macOS

Buka Terminal:

```bash
launchctl bootout "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.fahmie.ruqyah.plist" 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/com.fahmie.ruqyah.plist"
rm -rf "$HOME/.local/share/ruqyah"
```

### Windows — PowerShell

Buka PowerShell:

```powershell
Get-CimInstance Win32_Process -Filter "name='powershell.exe'" |
Where-Object { $_.CommandLine -like '*Ruqyah\ruqyah.ps1*' } |
ForEach-Object { Stop-Process -Id $_.ProcessId -Force }

Unregister-ScheduledTask -TaskName "Ruqyah-Logon" -Confirm:$false -ErrorAction SilentlyContinue
Unregister-ScheduledTask -TaskName "Ruqyah-Daily-1400" -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Ruqyah" -Recurse -Force -ErrorAction SilentlyContinue
```

### Windows — CMD

Buka CMD:

```cmd
powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"name='powershell.exe'\" | Where-Object { $_.CommandLine -like '*Ruqyah\ruqyah.ps1*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }; Unregister-ScheduledTask -TaskName 'Ruqyah-Logon' -Confirm:$false -ErrorAction SilentlyContinue; Unregister-ScheduledTask -TaskName 'Ruqyah-Daily-1400' -Confirm:$false -ErrorAction SilentlyContinue; Remove-Item (Join-Path $env:LOCALAPPDATA 'Ruqyah') -Recurse -Force -ErrorAction SilentlyContinue"
```

## Nota penting
- Komputer perlu hidup, tidak berada dalam Sleep, dan pengguna perlu log masuk pada waktu jadual untuk audio dimainkan.
- Jika komputer dimatikan atau tidur pada 2:00 petang, main semula tidak dijamin tepat pada waktunya.
- Audio distrim satu ayat pada satu masa; fail sementara dipadam selepas dimainkan.
- Senarai ayat ditetapkan dalam `ruqyah.sh` dan `ruqyah.ps1`.

## Sumber audio
EveryAyah — Saad Al-Ghamdi, folder `Ghamadi_40kbps`. Sila semak syarat penggunaan dan atribusi sumber sebelum pengedaran semula.
