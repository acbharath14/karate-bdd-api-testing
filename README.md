# Karate API Testing Showcase

BDD API tests written in plain English, with no Java step definitions to maintain. This repo shows how Karate tests a REST API end to end: read, create, update, delete, and the negative cases that prove the API rejects bad input properly.

The demo API is ReqRes (https://reqres.in), a free public API built for practice. It behaves like a real user API and needs no account, no setup, and no key to start.

## What is Karate

Karate is a test framework built on Gherkin, the Given-When-Then language also used by Cucumber. The difference: in Cucumber you write the Gherkin and then write Java glue code for every step. In Karate the steps already exist. You write the feature file and you are done.

A test looks like this:

```gherkin
Scenario: Getting one user returns the expected name and email
  Given path 'users', 2
  When method get
  Then status 200
  And match response.data.first_name == 'Janet'
```

That is the whole test. No page objects, no HTTP client code, no assertions library to learn. If you can read the scenario, you can write one.

## Prerequisites

You need two things, and the preflight script checks both for you:

- **Java 17 or newer.** Karate 1.5.x requires Java 17. Temurin is the recommended build.
- **Maven 3.6.3 or newer.** The build tool that downloads dependencies and runs the tests.

No browser is needed. This repo tests an HTTP API, not a web page.

## Quickstart

```bash
git clone <your-repo-url>
cd <repo-name>
mvn test
```

That is the whole setup. The first run downloads Karate and its dependencies (one time only), checks Java and Maven with the preflight script, runs all 11 scenarios against ReqRes, and writes the reports.

If preflight reports something missing, it either installs it (MacPorts on macOS, apt on Linux, winget on Windows) or prints the exact command to fix it. To skip the check: `mvn test -Dpreflight.skip=true`.

## Project layout

| Path | What it is |
| ---- | ---------- |
| `pom.xml` | The Maven build file. Every version is pinned here: Karate 1.5.2, JUnit 5.11.4, Java 17. |
| `src/test/java/com/acbharath14/karate/KarateTest.java` | The JUnit 5 runner. It points Karate at the feature files. You never edit this to add a test. |
| `src/test/java/karate-config.js` | Shared setup for every scenario: the base URL and the optional ReqRes API key. |
| `src/test/resources/features/` | The tests themselves, one file per area. See the table below. |
| `scripts/preflight.sh` | Setup check for macOS and Linux. Runs automatically inside `mvn test`. |
| `scripts/preflight.ps1` | Setup check for Windows. Runs automatically inside `mvn test`. |
| `TESTING.md` | How to run the suite, what it covers, and how to read the reports. |
| `.github/workflows/ci.yml` | GitHub Actions workflow. See the note at the top of that file before pushing it. |

## The feature files

| File | What it covers | Scenarios |
| ---- | -------------- | --------- |
| `users-get.feature` | Reading one user, reading a page of users, reading a user that does not exist | 3 |
| `users-create-update.feature` | Creating a user, full update with PUT, partial update with PATCH | 3 |
| `users-delete.feature` | Deleting a user | 1 |
| `auth-negative.feature` | Login and registration, valid and missing-password cases | 4 |

## Running the tests

Run everything:

```bash
mvn test
```

Run only the fast smoke scenarios:

```bash
mvn test -Dkarate.tags=@smoke
```

Run only the negative cases:

```bash
mvn test -Dkarate.tags=@negative
```

After a run, open the Karate HTML report at `target/karate-reports/karate-summary.html`. It lists every scenario, what passed, what failed, and the request and response of each step. The JUnit XML reports are in `target/surefire-reports/`. Full detail, including the coverage matrix, is in TESTING.md.

## How to add a test

1. Pick the feature file for the area you are testing, or create a new `.feature` file in `src/test/resources/features/`.
2. Copy a scenario that looks close to what you need.
3. Change the path, the method, the request body, and the match lines.
4. Run `mvn test` and read the failure in the HTML report if it goes red. Karate prints the actual response next to your expected one.

Scenario titles state the behavior and the expected outcome in plain words, for example "Creating a user returns 201 with an id and a creation timestamp". Keep that style.

## How to point the suite at another API

1. Change `baseUrl` in `src/test/java/karate-config.js`, or pass it on the command line: `mvn test -Dkarate.baseUrl=https://your-api.example.com/api`.
2. Rewrite the feature files for your endpoints. The structure stays the same: path, method, status, match.

## The ReqRes daily limit

ReqRes lets you call the API without a key, on a shared demo key with a low daily request limit. The suite makes about 11 requests per run, so normal use is fine. If you ever see failures that look like rate limiting, get a free personal key at https://reqres.in and set it:

```bash
export REQRES_API_KEY=your-key-here
mvn test
```

On Windows: `$env:REQRES_API_KEY = "your-key-here"; mvn test`. The key is read from the environment only. It is never written to a file and never committed.

## Troubleshooting

- **Preflight fails on Java:** install Temurin 17 from https://adoptium.net/temurin/releases/ and make sure `java -version` prints 17 or newer.
- **Preflight fails on Maven:** install it from https://maven.apache.org/download.cgi and add its `bin` folder to PATH.
- **A test fails with a connection error:** check your internet connection. ReqRes is a live public API, so the suite needs to reach it.
- **A test fails with a 429 status:** the shared demo key hit its daily limit. Set your own `REQRES_API_KEY` as above and re-run.
- **Windows: `mvn test` fails before any test runs:** the preflight step runs `preflight.ps1` through PowerShell. Run `mvn test -Dpreflight.skip=true` to confirm the tests themselves are fine, then run the script by hand to see the error: `powershell -ExecutionPolicy Bypass -File scripts\preflight.ps1`.

## Continuous integration

`.github/workflows/ci.yml` runs `mvn test` on every push and pull request to main, and uploads the Karate HTML report and the Surefire reports as artifacts (kept 7 days). Read the note at the top of that file: the workflow file goes through the GitHub web UI, not through an API push.
