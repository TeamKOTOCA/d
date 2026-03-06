$MaxPerPage = 10
$PreviewMinWidth = 100
$PreviewMaxLines = 8

function Read-Key {
    try {
        return [System.Console]::ReadKey($true)
    }
    catch {
        $line = Read-Host
        if ($null -eq $line -or $line.Length -eq 0) {
            return [PSCustomObject]@{ Key = [ConsoleKey]::Enter; KeyChar = [char]13 }
        }
        return [PSCustomObject]@{ Key = [ConsoleKey]::NoName; KeyChar = $line.Substring(0, 1) }
    }
}

function Get-DirectoryList {
    param(
        [string]$FilterText
    )

    $dirs = @('..')
    $childDirs = Get-ChildItem -LiteralPath . -Directory -ErrorAction SilentlyContinue | Sort-Object -Property Name

    foreach ($dir in $childDirs) {
        if ([string]::IsNullOrWhiteSpace($FilterText) -or $dir.Name -like "*$FilterText*") {
            $dirs += $dir.Name
        }
    }

    return $dirs
}

function Get-PreviewLines {
    param(
        [string]$Path,
        [int]$MaxLines
    )

    $items = Get-ChildItem -LiteralPath $Path -ErrorAction SilentlyContinue | Sort-Object -Property Name

    if ($null -eq $items -or $items.Count -eq 0) {
        return @('(empty)')
    }

    $lines = @()
    foreach ($item in $items | Select-Object -First $MaxLines) {
        if ($item.PSIsContainer) {
            $lines += "[D] $($item.Name)"
        }
        else {
            $lines += "[F] $($item.Name)"
        }
    }

    if ($items.Count -gt $MaxLines) {
        $lines += "... and $($items.Count - $MaxLines) more"
    }

    return $lines
}

function Resolve-PreviewTarget {
    param(
        [string]$Name
    )

    if ($Name -eq '..') {
        return (Resolve-Path -LiteralPath '..').Path
    }

    return (Resolve-Path -LiteralPath $Name).Path
}

while ($true) {
    $filterText = ''
    $page = 0
    $cursor = 0

    while ($true) {
        $dirs = Get-DirectoryList -FilterText $filterText
        $total = $dirs.Count
        if ($total -eq 0) {
            $dirs = @('..')
            $total = 1
        }

        $totalPages = [Math]::Ceiling($total / $MaxPerPage)
        if ($page -ge $totalPages) {
            $page = [Math]::Max(0, $totalPages - 1)
        }

        $start = $page * $MaxPerPage
        $end = [Math]::Min($start + $MaxPerPage, $total)
        $pageCount = $end - $start

        if ($pageCount -le 0) {
            $cursor = 0
            $selectedIndex = 0
        }
        else {
            if ($cursor -ge $pageCount) {
                $cursor = $pageCount - 1
            }
            if ($cursor -lt 0) {
                $cursor = 0
            }
            $selectedIndex = $start + $cursor
        }

        Clear-Host
        Write-Host "Current: $(Get-Location)"
        if ([string]::IsNullOrWhiteSpace($filterText)) {
            Write-Host "Page $($page + 1) / $totalPages"
        }
        else {
            Write-Host "Page $($page + 1) / $totalPages | Search: $filterText"
        }
        Write-Host '--------------------'

        $disp = 0
        for ($i = $start; $i -lt $end; $i++) {
            $item = $dirs[$i]
            if ($item -eq '..') {
                $item = '.. (parent)'
            }

            $cursorMark = ' '
            if (($i - $start) -eq $cursor) {
                $cursorMark = '>'
            }

            Write-Host ("{0} {1}) {2}" -f $cursorMark, $disp, $item)
            $disp++
        }

        Write-Host '--------------------'
        Write-Host '0-9=select, j/k or ↑/↓=cursor, n/p=page, /=search, c=clear search, Enter=quit'

        if ([System.Console]::WindowWidth -ge $PreviewMinWidth -and $pageCount -gt 0) {
            try {
                $previewTarget = Resolve-PreviewTarget -Name $dirs[$selectedIndex]
                Write-Host '--- Preview ---'
                Write-Host $previewTarget
                $previewLines = Get-PreviewLines -Path $previewTarget -MaxLines $PreviewMaxLines
                foreach ($line in $previewLines) {
                    Write-Host $line
                }
            }
            catch {
                Write-Host '--- Preview ---'
                Write-Host '(preview unavailable)'
            }
        }

        $keyInfo = Read-Key

        if ($keyInfo.Key -eq [ConsoleKey]::Enter) {
            return
        }

        $choice = $keyInfo.KeyChar.ToString()

        if ($choice -match '^[0-9]$') {
            $real = $start + [int]$choice
            if ($real -ge $start -and $real -lt $end) {
                try {
                    Set-Location -LiteralPath $dirs[$real] -ErrorAction Stop
                    break
                }
                catch {
                    Start-Sleep -Milliseconds 700
                }
            }
            continue
        }

        switch ($keyInfo.Key) {
            ([ConsoleKey]::UpArrow) {
                if ($cursor -gt 0) { $cursor-- }
                continue
            }
            ([ConsoleKey]::DownArrow) {
                if ($cursor -lt ($pageCount - 1)) { $cursor++ }
                continue
            }
        }

        switch -Regex ($choice) {
            '^[nN]$' {
                if ($page -lt ($totalPages - 1)) {
                    $page++
                    $cursor = 0
                }
            }
            '^[pP]$' {
                if ($page -gt 0) {
                    $page--
                    $cursor = 0
                }
            }
            '^[jJ]$' {
                if ($cursor -lt ($pageCount - 1)) { $cursor++ }
            }
            '^[kK]$' {
                if ($cursor -gt 0) { $cursor-- }
            }
            '^/$' {
                Write-Host
                $filterText = Read-Host 'search'
                $page = 0
                $cursor = 0
            }
            '^[cC]$' {
                $filterText = ''
                $page = 0
                $cursor = 0
            }
        }
    }
}
