<#
GTA 6 Clip Desk (gtavi-claudecode): one-time setup for Windows 10/11.

Run in PowerShell (no admin needed):
  irm https://raw.githubusercontent.com/art00000000000art-jpg/gtavi-claudecode/main/setup-windows.ps1 | iex

What it does:
  1. Installs Python 3.12 and ffmpeg with winget if they are missing.
  2. Installs the Python packages from requirements.txt.
  3. Asks 4 questions and creates your page folder in Documents
     (playbook, facts, scoreboard, campaigns, media folders, CLAUDE.md).
  4. Installs the Claude Code plugin if the "claude" command is available.
  5. Copies the first-run prompt to your clipboard.
It never posts anything and never deletes files. Existing files in the page folder are kept.
#>

function Install-GtaClipDesk {
    $ErrorActionPreference = 'Continue'
    $ProgressPreference = 'SilentlyContinue'
    $Repo = 'art00000000000art-jpg/gtavi-claudecode'
    $Utf8 = New-Object System.Text.UTF8Encoding $false

    function Say($msg)  { Write-Host $msg -ForegroundColor Cyan }
    function Ok($msg)   { Write-Host "  OK  $msg" -ForegroundColor Green }
    function Warn($msg) { Write-Host "  !   $msg" -ForegroundColor Yellow }
    function Has($name) { [bool](Get-Command $name -ErrorAction SilentlyContinue) }

    function Refresh-Path {
        $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
    }

    function Test-Python($exe) {
        try {
            $out = & $exe -c "import sys; print(1 if sys.version_info >= (3, 10) else 0)" 2>$null
            return (($LASTEXITCODE -eq 0) -and ("$out".Trim() -eq '1'))
        } catch {
            return $false
        }
    }

    function Find-Python {
        foreach ($c in @('python', 'py')) {
            if ((Has $c) -and (Test-Python $c)) {
                $exe = & $c -c "import sys; print(sys.executable)"
                return "$exe".Trim()
            }
        }
        foreach ($d in @((Join-Path $env:LOCALAPPDATA 'Programs\Python'), $env:ProgramFiles)) {
            if ($d -and (Test-Path $d)) {
                $hit = Get-ChildItem -Path $d -Directory -Filter 'Python3*' -ErrorAction SilentlyContinue |
                    Sort-Object Name -Descending |
                    ForEach-Object { Join-Path $_.FullName 'python.exe' } |
                    Where-Object { (Test-Path $_) -and (Test-Python $_) } |
                    Select-Object -First 1
                if ($hit) { return $hit }
            }
        }
        return $null
    }

    function Ask($question, $default) {
        $a = Read-Host "  $question [$default]"
        if ([string]::IsNullOrWhiteSpace($a)) { return $default }
        return $a.Trim()
    }

    function Write-New($rel, $text) {
        $p = Join-Path $page $rel
        if (Test-Path $p) { Warn "kept your existing $rel"; return }
        [IO.File]::WriteAllText($p, $text, $Utf8)
    }

    Say ''
    Say '=== GTA 6 Clip Desk: Windows setup ==='
    Say ''

    if (-not (Has 'winget')) {
        Warn 'winget was not found. Install "App Installer" from the Microsoft Store, then run this again.'
        return
    }

    # 1. Python
    Say '[1/5] Python'
    $py = Find-Python
    if ($py) {
        Ok "found $py"
    } else {
        Say '  Installing Python 3.12 with winget...'
        & winget install -e --id Python.Python.3.12 --scope user --accept-package-agreements --accept-source-agreements --override '/quiet InstallAllUsers=0 PrependPath=1 Include_test=0'
        Refresh-Path
        $py = Find-Python
        if (-not $py) {
            Warn 'Python did not install. Install Python 3.12 from https://www.python.org/downloads/ (tick "Add python.exe to PATH"), then run this again.'
            return
        }
        Ok "installed $py"
    }
    # The plugin's skills call "python", so make sure that name works.
    if (-not ((Has 'python') -and (Test-Python 'python'))) {
        $pdir = Split-Path $py
        $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
        [Environment]::SetEnvironmentVariable('Path', "$pdir;$pdir\Scripts;$userPath", 'User')
        Refresh-Path
        Warn "added $pdir to your user PATH so Claude can run 'python'"
    }

    # 2. ffmpeg
    Say '[2/5] ffmpeg'
    if ((Has 'ffmpeg') -and (Has 'ffprobe')) {
        Ok 'found'
    } else {
        Say '  Installing ffmpeg with winget...'
        & winget install -e --id Gyan.FFmpeg --accept-package-agreements --accept-source-agreements
        Refresh-Path
        if (Has 'ffmpeg') { Ok 'installed' } else { Warn 'installed, but this window cannot see it yet. It will work after you restart Claude.' }
    }

    # 3. Plugin files and Python packages
    Say '[3/5] Python packages (a few minutes the first time)'
    $tmp = Join-Path $env:TEMP ('gtavi-setup-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    New-Item -ItemType Directory -Path $tmp -Force | Out-Null
    $zip = Join-Path $tmp 'repo.zip'
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri "https://github.com/$Repo/archive/refs/heads/main.zip" -OutFile $zip -UseBasicParsing -ErrorAction Stop
        Expand-Archive -Path $zip -DestinationPath $tmp -Force -ErrorAction Stop
    } catch {
        Warn "could not download https://github.com/$Repo : $($_.Exception.Message)"
        return
    }
    $srcDir = Get-ChildItem -Path $tmp -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'requirements.txt') } | Select-Object -First 1
    if (-not $srcDir) { Warn 'the downloaded files look wrong (no requirements.txt).'; return }
    $src = $srcDir.FullName
    & $py -m pip install --disable-pip-version-check -U -r (Join-Path $src 'requirements.txt')
    if ($LASTEXITCODE -ne 0) {
        Warn 'pip install failed. Scroll up for the red error text and send it to whoever helps you.'
        return
    }
    Ok 'packages installed'

    # 4. Page folder
    Say ''
    Say '[4/5] Your page. Four questions; press Enter to keep the value in brackets.'
    $name = Ask 'Page name' 'GTA 6 Clips'
    $defHandle = ($name -replace '[^A-Za-z0-9_]', '').ToLower()
    if (-not $defHandle) { $defHandle = 'gta6clips' }
    $handle = (Ask 'Handle, without @' $defHandle).TrimStart('@')
    $platforms = Ask 'Platforms' 'X, Instagram Reels, TikTok, YouTube Shorts'
    Write-Host '  Niche angle: 1 = tips and hidden spots, 2 = fast news, 3 = funny moments, 4 = cars and customization'
    $n = Ask 'Pick 1-4 or type your own' '1'
    $niches = @{ '1' = 'tips and hidden spots'; '2' = 'fast news'; '3' = 'funny moments'; '4' = 'cars and customization' }
    if ($niches.ContainsKey($n)) { $niche = $niches[$n] } else { $niche = $n }
    $tz = Ask 'Time zone' ([TimeZoneInfo]::Local.DisplayName)

    $docs = [Environment]::GetFolderPath('MyDocuments')
    $safe = ($name -replace '[\\/:*?"<>|]', '_').Trim().TrimEnd('.')
    if (-not $safe) { $safe = 'GTA 6 page' }
    $page = Join-Path $docs $safe
    New-Item -ItemType Directory -Path $page -Force | Out-Null
    foreach ($d in @('media', 'media\official', 'media\raw', 'media\edits')) {
        New-Item -ItemType Directory -Path (Join-Path $page $d) -Force | Out-Null
    }

    $pb = [IO.File]::ReadAllText((Join-Path $src 'skills\playbook\references\playbook.md'), $Utf8)
    $pb = $pb.Replace('[PAGE NAME]', $name).Replace('[HANDLE]', $handle).Replace('[TIME ZONE]', $tz)
    $m = [regex]::Match($pb, '\[PLATFORMS[^\]]*\]')
    if ($m.Success) { $pb = $pb.Replace($m.Value, $platforms) }
    $m = [regex]::Match($pb, '\[NICHE ANGLE[^\]]*\]')
    if ($m.Success) { $pb = $pb.Replace($m.Value, $niche) }
    Write-New 'playbook.md' $pb

    Write-New 'facts.md' "# Facts`n`nVerified facts only. One per line: the fact, the official source link, the date checked.`n"
    Write-New 'idea-bank.md' "# Idea bank`n`nReady-to-go drafts by pillar.`n"
    Write-New 'watchlist.md' "# Watchlist`n`nOfficial accounts, creators, streamers and subreddits to monitor.`n"
    Write-New 'log.md' "# Post log`n`nEvery post that went out: time, text, media, credit, link.`n"
    Write-New 'scoreboard.csv' "post_id,date,time,platform,pillar,format,hook,length_sec,credit,views_12h,views_24h,views_72h,likes,reposts_or_shares,replies_or_comments,saves_or_bookmarks,followers_at_read,test_name,notes`n"
    Write-New 'learning.md' "# Learning`n`n## Wins`n`n## Losses`n`n## Current Rules`n"
    Write-New 'takedowns.md' "# Takedowns`n`nAny removal request and what we did.`n"
    Write-New 'campaigns.md' "# Campaigns`n`n| name | platform | rate per 1K views | budget left | rules | link | checked on |`n| --- | --- | --- | --- | --- | --- | --- |`n"
    Write-New 'payouts.csv' "date,campaign,platform,post_url,views,rate_per_1k,est_payout,status`n"

    $today = Get-Date -Format 'yyyy-MM-dd'
    $claudeMd = @"
# GTA 6 page: $name (@$handle)

This is the page folder for the gtavi-claudecode plugin. Setup is already done: Python, ffmpeg and the
Python packages are installed and the files below exist. Do not ask the setup questions again.

- Platforms: $platforms
- Niche angle: $niche
- Time zone: $tz
- Set up on: $today

Work from playbook.md in this folder (the customized copy). Use the gtavi-claudecode skills:
campaign-finder, trend-radar, stream-finder, moment-finder, clip-cutter, hook-writer, rule-check,
learning-loop. Run the scripts from this folder so jobs/ is created here.

If the gtavi-claudecode skills are not available, tell the human to type these two commands:
  /plugin marketplace add $Repo
  /plugin install gtavi-claudecode@gtavi-claudecode

The human approves every post and posts it. Never auto-upload. No leaks, no piracy,
no story spoilers or cutscene clips.
"@
    Write-New 'CLAUDE.md' ($claudeMd -replace "`r`n", "`n")

    $prompt = 'Use gtavi-claudecode. My page folder is set up: read CLAUDE.md and playbook.md here. Find live clipping campaigns, show today''s trending GTA 6 videos and live streams, find the best moments in the top one, cut my first 3 clips with hooks, check them against the rules, and tell me what to post where.'
    $start = @"
GTA 6 Clip Desk: start here

1. Restart the Claude app, so it sees Python and ffmpeg.
2. In Claude, open the Code tab and choose this folder:
   $page
3. If the plugin is not installed yet, type these two commands there:
   /plugin marketplace add $Repo
   /plugin install gtavi-claudecode@gtavi-claudecode
4. Paste this first-run prompt:

$prompt

You approve every post. Nothing is uploaded automatically.
"@
    Write-New 'START-HERE.txt' $start
    Ok "page folder: $page"

    # 5. Claude Code plugin
    Say '[5/5] Claude Code plugin'
    $pluginOk = $false
    if (Has 'claude') {
        & claude plugin marketplace add $Repo
        & claude plugin install gtavi-claudecode@gtavi-claudecode
        if ($LASTEXITCODE -eq 0) { $pluginOk = $true; Ok 'plugin installed' }
    }
    if (-not $pluginOk) {
        Warn 'install the plugin from the Code tab with the two /plugin commands in START-HERE.txt'
    }

    try { Set-Clipboard -Value $prompt; $clip = $true } catch { $clip = $false }
    Remove-Item -Path $tmp -Recurse -Force -ErrorAction SilentlyContinue

    Say ''
    Say '=== Done ==='
    Write-Host "Page folder: $page"
    Write-Host '1. Restart the Claude app.'
    Write-Host '2. Claude > Code tab > choose the page folder above.'
    if (-not $pluginOk) {
        Write-Host '3. Type:  /plugin marketplace add art00000000000art-jpg/gtavi-claudecode'
        Write-Host '   Then:  /plugin install gtavi-claudecode@gtavi-claudecode'
    }
    if ($clip) { Write-Host 'Then paste the first-run prompt: it is already in your clipboard (and in START-HERE.txt).' }
    else { Write-Host 'Then paste the first-run prompt from START-HERE.txt.' }
    Invoke-Item -Path $page
}

try {
    Install-GtaClipDesk
} catch {
    Write-Host "Setup stopped: $($_.Exception.Message)" -ForegroundColor Red
}
