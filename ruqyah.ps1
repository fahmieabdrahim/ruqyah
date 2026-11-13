# Ruqyah player for Windows
$ErrorActionPreference = "Stop"
$baseUrl = "https://everyayah.com/data/Ghamadi_40kbps"
$mutex = New-Object System.Threading.Mutex($false, "Local\RuqyahSaadAlGhamdi")
$hasLock = $false
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("Ruqyah-" + [guid]::NewGuid().ToString("N"))
$player = $null
$originalVolume = $null
$originalMuted = $false
$volumeCaptured = $false

# Akses Windows Core Audio untuk mengawal volume output sistem.
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

[ComImport]
[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDeviceEnumerator {
    int EnumAudioEndpoints(int dataFlow, int stateMask, out IntPtr devices);
    int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice device);
    int GetDevice(string id, out IMMDevice device);
    int RegisterEndpointNotificationCallback(IntPtr client);
    int UnregisterEndpointNotificationCallback(IntPtr client);
}

[ComImport]
[Guid("D666063F-1587-4E43-81F1-B948E807363F")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDevice {
    int Activate(ref Guid iid, int clsctx, IntPtr activationParams, out IAudioEndpointVolume volume);
    int OpenPropertyStore(int access, out IntPtr properties);
    int GetId(out IntPtr id);
    int GetState(out int state);
}

[ComImport]
[Guid("5CDF2C82-841E-4546-9722-0CF74078229A")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioEndpointVolume {
    int RegisterControlChangeNotify(IntPtr notify);
    int UnregisterControlChangeNotify(IntPtr notify);
    int GetChannelCount(out uint count);
    int SetMasterVolumeLevel(float level, ref Guid context);
    int SetMasterVolumeLevelScalar(float level, ref Guid context);
    int GetMasterVolumeLevel(out float level);
    int GetMasterVolumeLevelScalar(out float level);
    int SetChannelVolumeLevel(uint channel, float level, ref Guid context);
    int SetChannelVolumeLevelScalar(uint channel, float level, ref Guid context);
    int GetChannelVolumeLevel(uint channel, out float level);
    int GetChannelVolumeLevelScalar(uint channel, out float level);
    int SetMute([MarshalAs(UnmanagedType.Bool)] bool mute, ref Guid context);
    int GetMute([MarshalAs(UnmanagedType.Bool)] out bool mute);
    int GetVolumeStepInfo(out uint step, out uint stepCount);
    int VolumeStepUp(ref Guid context);
    int VolumeStepDown(ref Guid context);
    int QueryHardwareSupport(out uint mask);
    int GetVolumeRange(out float min, out float max, out float increment);
}

public static class RuqyahAudioVolume {
    static IAudioEndpointVolume GetEndpoint() {
        var enumerator = (IMMDeviceEnumerator)new MMDeviceEnumeratorComObject();
        IMMDevice device;
        Marshal.ThrowExceptionForHR(enumerator.GetDefaultAudioEndpoint(0, 1, out device));
        Guid iid = new Guid("5CDF2C82-841E-4546-9722-0CF74078229A");
        IAudioEndpointVolume endpoint;
        Marshal.ThrowExceptionForHR(device.Activate(ref iid, 23, IntPtr.Zero, out endpoint));
        return endpoint;
    }
    public static float Get() {
        float value;
        Marshal.ThrowExceptionForHR(GetEndpoint().GetMasterVolumeLevelScalar(out value));
        return value;
    }
    public static void Set(float value) {
        Guid context = Guid.Empty;
        Marshal.ThrowExceptionForHR(GetEndpoint().SetMasterVolumeLevelScalar(Math.Max(0f, Math.Min(1f, value)), ref context));
    }
    public static bool GetMute() {
        bool muted;
        Marshal.ThrowExceptionForHR(GetEndpoint().GetMute(out muted));
        return muted;
    }
    public static void SetMute(bool muted) {
        Guid context = Guid.Empty;
        Marshal.ThrowExceptionForHR(GetEndpoint().SetMute(muted, ref context));
    }
}

[ComImport]
[Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")]
class MMDeviceEnumeratorComObject {}
'@

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

  $originalVolume = [RuqyahAudioVolume]::Get()
  $originalMuted = [RuqyahAudioVolume]::GetMute()
  $volumeCaptured = $true

  New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
  Add-Type -AssemblyName PresentationCore
  $player = New-Object System.Windows.Media.MediaPlayer
  Write-Output "Volume dikunci pada 30% sepanjang bacaan."

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
        [RuqyahAudioVolume]::Set(0.30)
        [RuqyahAudioVolume]::SetMute($false)
        $player.Play()
        $deadline = (Get-Date).Add($duration).AddSeconds(8)
        while ($player.Position -lt $duration -and (Get-Date) -lt $deadline) {
          [RuqyahAudioVolume]::Set(0.30)
          [RuqyahAudioVolume]::SetMute($false)
          Start-Sleep -Milliseconds 200
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
  if ($volumeCaptured) {
    try {
      [RuqyahAudioVolume]::Set($originalVolume)
      [RuqyahAudioVolume]::SetMute($originalMuted)
    } catch { Write-Warning "Tetapan volume asal tidak dapat dipulihkan secara automatik." }
  }
  Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
  if ($hasLock) { $mutex.ReleaseMutex() }
  $mutex.Dispose()
  Write-Output "Playback tamat. Kawalan volume kembali normal."
}
