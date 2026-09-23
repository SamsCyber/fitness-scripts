# Fitness Scripts

A weekly check-in export that combines two (for now) data sources into one CSV:

- **[Mfp-Scraper](https://github.com/samscyber/Mfp-Scraper)** (Python): daily protein, carbs and fat from your MyFitnessPal food diary.
- **[GoogleHealthDataRetriever](https://github.com/samscyber/GoogleHealthDataRetriever)** (Go): daily steps and sleep times from the Google Health API (Fitbit data).

`run-macros_and_steps.ps1` runs both for the last 7 days and produces a single `weekly-checkin.csv`, ready to copy into a coaching spreadsheet.

Each project works on its own too. This repo just ties them together.

## Getting started

### 1. Clone with submodules

The two projects are included as git submodules, so clone with:
```powershell
git clone --recurse-submodules https://github.com/samscyber/fitness-scripts.git
```
If you already cloned without `--recurse-submodules` and the project folders are empty, run:
```powershell
git submodule update --init
```

### 2. Set up each project

Follow the setup steps in each project's README:

- [Mfp-Scraper setup](Mfp-Scraper/README.md): Python virtual environment, dependencies, and MyFitnessPal login.
- [GoogleHealthDataRetriever setup](GoogleHealthDataRetriever/README.md): Google Cloud project, OAuth client, and Go.

It's worth running each one on its own once before using the combined script, so the first-time logins are out of the way.

### 3. Allow the scripts to run (Windows)

If you downloaded the scripts rather than cloning, clear Windows' download warning once:
```powershell
Unblock-File .\run-macros_and_steps.ps1
```

## Usage

From this folder:
```powershell
.\run-macros_and_steps.ps1
```
or double-click **`run-macros_and_steps.bat`**, which launches the PowerShell script and keeps the window open at the end.

The script:

1. Runs the MyFitnessPal export, which creates the CSV with the week's macros.
2. Runs the Google Health export, which appends steps and sleep underneath.
3. Moves the combined CSV to this folder as `weekly-checkin.csv` and prints it.

If either step fails, the script stops, so you never get health data appended to an old macros file.

Either project may prompt you to log in again when its session has expired: MyFitnessPal via the browser or cookie paste, and Google via a browser sign-in.

### Google Health: built binary or source

The script runs `GoogleHealthDataRetriever\health-fetch.exe` if it exists. If not, it falls back to `go run`, which needs Go installed. Building once makes every run faster:
```powershell
cd GoogleHealthDataRetriever
go build -o health-fetch.exe
```
Remember to rebuild after changing the Go code, or delete the `.exe` so the script falls back to running from source.

## Output

```
2026-09-17 to 2026-09-23
Protein (g),Carbs (g),Fats (g)
199,216,43
...

2026-09-17 to 2026-09-23
Date,Steps,Asleep,Woke,Sleep (h)
2026-09-17,14119,,,
...
```

## Folder layout

```
fitness-scripts/
├── run-macros_and_steps.ps1    # runs both exports and combines the CSV
├── run-macros_and_steps.bat    # double-click launcher for the script
├── Mfp-Scraper/                # submodule
└── GoogleHealthDataRetriever/  # submodule
```
If you rename either project folder, update `$mfpDir` or `$healthDir` at the top of `run-macros_and_steps.ps1` to match.

## Updating the projects

The submodules are pinned to specific commits. To pull the latest version of both:
```powershell
git submodule update --remote
git add Mfp-Scraper GoogleHealthDataRetriever
git commit -m "Update submodules"
```
After committing and pushing changes inside one of the project folders, commit the updated pointer here the same way.

## Privacy

The CSV contains personal health data and is git-ignored in this repo and in both projects. Login secrets (`.env`, `client_secret.json`, `token.json`) stay inside their own project folders and are git-ignored there. Don't commit or share any of them.