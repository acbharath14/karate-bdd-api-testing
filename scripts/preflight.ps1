# Preflight checks for the Karate API testing showcase (Windows).
#
# Verifies Java 17+ and Maven are available, installing what is missing
# via winget. This repo tests an HTTP API, so no browser or driver is
# needed and none is checked.
#
# Runs automatically inside `mvn test` (bound to the `validate` phase in
# pom.xml, in the preflight-windows profile). Skip with:
#   mvn test -Dpreflight.skip=true
# or: $env:PREFLIGHT_SKIP = "true"; mvn test

if ($env:PREFLIGHT_SKIP -eq "true") {
    Write-Host "preflight: skipped (PREFLIGHT_SKIP=true)"
    exit 0
}

$failed = $false

function Get-JavaMajor {
    try {
        $out = & java -version 2>&1 | Select-Object -First 1
        if ($out -match '"(\d+)') { return [int]$Matches[1] }
    } catch { }
    return 0
}

Write-Host "preflight: checking Java..."
$java = Get-Command java -ErrorAction SilentlyContinue
if ($java) {
    $major = Get-JavaMajor
    Write-Host "  found: $(& java -version 2>&1 | Select-Object -First 1)"
    if ($major -lt 17) {
        Write-Host "  ERROR: Java 17+ is required (Karate 1.5.x needs Java 17)."
        $failed = $true
    }
} else {
    Write-Host "  Java not found."
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        Write-Host "  installing Temurin 17 via winget..."
        winget install -e --id EclipseAdoptium.Temurin.17.JDK --accept-source-agreements --accept-package-agreements
        if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
            Write-Host "  winget ran but java is still not on PATH. Close and reopen the terminal, then re-run."
            $failed = $true
        }
    } else {
        Write-Host "  Fix: install a Temurin 17 JDK from https://adoptium.net/temurin/releases/"
        $failed = $true
    }
}

Write-Host "preflight: checking Maven..."
$mvn = Get-Command mvn -ErrorAction SilentlyContinue
if ($mvn) {
    Write-Host "  found: $(& mvn -version 2>&1 | Select-Object -First 1)"
} else {
    Write-Host "  Maven not found."
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        Write-Host "  installing Maven via winget..."
        winget install -e --id Maven.Maven --accept-source-agreements --accept-package-agreements
        if (-not (Get-Command mvn -ErrorAction SilentlyContinue)) {
            Write-Host "  winget ran but mvn is still not on PATH. Close and reopen the terminal, then re-run."
            $failed = $true
        }
    } else {
        Write-Host "  Fix: install Maven from https://maven.apache.org/download.cgi and add it to PATH"
        $failed = $true
    }
}

if ($failed) {
    Write-Host "preflight: FAILED. Fix the items above, then re-run."
    Write-Host "  (Skip this check with: mvn test -Dpreflight.skip=true)"
    exit 1
}

Write-Host "preflight: OK"
