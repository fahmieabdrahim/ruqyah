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

Buka **Windows PowerShell** (bukan Command Prompt). Jalankan:

```powershell
irm https://raw.githubusercontent.com/fahmieabdrahim/ruqyah/main/install.ps1 | iex
```

Arahan ini mendaftarkan dua tugasan: ketika log masuk dan setiap hari pada 2:00 petang.

## Nota penting
- Komputer perlu hidup, tidak berada dalam Sleep, dan pengguna perlu log masuk pada waktu jadual untuk audio dimainkan.
- Jika komputer dimatikan atau tidur pada 2:00 petang, main semula tidak dijamin tepat pada waktunya.
- Audio distrim satu ayat pada satu masa; fail sementara dipadam selepas dimainkan.
- Senarai ayat ditetapkan dalam `ruqyah.sh` dan `ruqyah.ps1`.

## Sumber audio
EveryAyah — Saad Al-Ghamdi, folder `Ghamadi_40kbps`. Sila semak syarat penggunaan dan atribusi sumber sebelum pengedaran semula.

## Nyahpasang macOS

```bash
launchctl bootout "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.fahmie.ruqyah.plist" 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/com.fahmie.ruqyah.plist"
rm -rf "$HOME/.local/share/ruqyah"
```

## Nyahpasang Windows

Jalankan dalam PowerShell:

```powershell
Unregister-ScheduledTask -TaskName "Ruqyah-Logon" -Confirm:$false -ErrorAction SilentlyContinue
Unregister-ScheduledTask -TaskName "Ruqyah-Daily-1400" -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Ruqyah" -Recurse -Force
```
