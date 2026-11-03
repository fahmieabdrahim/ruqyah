# Ruqyah player for Windows
$ErrorActionPreference = "Stop"
$baseUrl = "https://everyayah.com/data/Ghamadi_40kbps"
$mutex = New-Object System.Threading.Mutex($false, "Local\RuqyahSaadAlGhamdi")
$hasLock = $false
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("Ruqyah-" + [guid]::NewGuid().ToString("N"))

$ranges = @(
  @{ Surah = 1; First = 1; Last = 7 },
  @{ Surah = 2; First = 1; Last = 5 },
  @{ Surah = 2; First = 102; Last = 102 },
  @{ Surah = 2; First = 163; Last = 164 },
  @{ Surah = 2; First = 255; Last = 255 },
  @{ Surah = 2; First = 285; Last = 286 },
  @{ Surah = 3; First = 18; Last = 19 },
  @{ Surah = 7; First = 117; Last = 122 },
  @{ Surah = 10; First = 81; Last = 82 },
  @{ Surah = 20; First = 69; Last = 69 },
  @{ Surah = 23; First = 115; Last = 118 },
  @{ Surah = 37; First = 1; Last = 10 },
  @{ Surah = 59; First = 21; Last = 24 },
  @{ Surah = 112; First = 1; Last = 4 },
  @{ Surah = 113; First = 1; Last = 5 },
  @{ Surah = 114; First = 1; Last = 6 }
)

try {
  $hasLock = $mutex.WaitOne(0)
  if (-not $hasLock) { Write-Output "Ruqyah sedang dimainkan; sesi baharu dibatalkan."; exit 0 }

  New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
  Add-Type -AssemblyName PresentationCore
  $player = New-Object System.Windows.Media.MediaPlayer

  foreach ($range in $ranges) {
    for ($ayah = $range.First; $ayah -le $range.Last; $ayah++) {
      $file = "{0:D3}{1:D3}.mp3" -f $range.Surah, $ayah
      $audioPath = Join-Path $tempDir $file
      $url = "$baseUrl/$file"
      Write-Output "Memainkan $file"

      try {
        Invoke-WebRequest -Uri $url -OutFile $audioPath -UseBasicParsing -TimeoutSec 45
        if (-not (Test-Path $audioPath) -or (Get-Item $audioPath).Length -eq 0) { continue }

        $player.Open([Uri]$audioPath)
        $waitUntil = (Get-Date).AddSeconds(30)
        while ($player.NaturalDuration.HasTimeSpan -eq $false -and (Get-Date) -lt $waitUntil) {
          Start-Sleep -Milliseconds 200
        }
        if (-not $player.NaturalDuration.HasTimeSpan) { $player.Close(); continue }

        $duration = $player.NaturalDuration.TimeSpan
        $player.Play()
        $deadline = (Get-Date).Add($duration).AddSeconds(8)
        while ($player.Position -lt $duration -and (Get-Date) -lt $deadline) {
          Start-Sleep -Milliseconds 250
        }
        $player.Stop()
        $player.Close()
      }
      catch {
        Write-Warning "Gagal memainkan $file : $($_.Exception.Message)"
        try { $player.Stop(); $player.Close() } catch {}
      }
      finally {
        Remove-Item $audioPath -Force -ErrorAction SilentlyContinue
      }
    }
  }
}
finally {
  try { if ($player) { $player.Close() } } catch {}
  Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
  if ($hasLock) { $mutex.ReleaseMutex() }
  $mutex.Dispose()
}
