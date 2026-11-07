# Testing

How to run the suite, what it covers, and how to read the reports.

## Running

Run everything (preflight checks Java and Maven first):

```bash
mvn test
```

Run only the smoke scenarios (one read, one create, one login):

```bash
mvn test -Dkarate.tags=@smoke
```

Run only the negative cases:

```bash
mvn test -Dkarate.tags=@negative
```

Run only the user-area features:

```bash
mvn test -Dkarate.tags=@users
```

Skip the preflight check (when you know the setup is fine):

```bash
mvn test -Dpreflight.skip=true
```

Point the suite at a different base URL without editing any file:

```bash
mvn test -Dkarate.baseUrl=https://your-api.example.com/api
```

## Coverage

11 scenarios across 4 feature files, against the ReqRes demo API. Each behavior is verified once, at the feature level. Variants of one behavior share one scenario where the expected outcome is the same; cases with different expected outcomes stay separate (success vs rejection, valid vs invalid input).

| Operation | Scenario | Expected result |
| --------- | -------- | --------------- |
| GET single user | Getting one user returns the expected name and email | 200, id 2, Janet Weaver, janet.weaver@reqres.in |
| GET user list | Getting the user list returns paginated data | 200, page 2, 6 per page, 12 total, 6 items |
| GET missing user | Getting a user that does not exist returns 404 with an empty body | 404, `{}` |
| POST create | Creating a user returns 201 with an id and a creation timestamp | 201, name and job echoed, id present, createdAt present |
| PUT update | Updating a user with PUT returns 200 with an updated timestamp | 200, name and job echoed, updatedAt present |
| PATCH update | Updating a user with PATCH returns 200 with an updated timestamp | 200, name and job echoed, updatedAt present |
| DELETE | Deleting a user returns 204 with no content | 204 |
| POST login, valid | Logging in with valid credentials returns 200 with a token | 200, token present |
| POST login, no password | Logging in without a password returns 400 with a Missing password error | 400, error `Missing password` |
| POST register, no password | Registering without a password returns 400 with a Missing password error | 400, error `Missing password` |
| POST register, valid | Registering with valid credentials returns 200 with an id and a token | 200, id 4, token present |

What is deliberately not covered: there is no 401 (unauthorized) scenario, because ReqRes has no endpoint that requires authentication. The negative cases above are the closest the API supports. There is no test for response time; Karate reports the time of each step, and slow steps are visible in the HTML report.

## Reports

After `mvn test`, two reports exist:

- **Karate HTML report:** `target/karate-reports/karate-summary.html`. Open it in a browser. It lists every feature and scenario, pass or fail, with the request and response of each step. This is the report to read first.
- **Surefire reports:** `target/surefire-reports/` (XML and text, one file per runner). These are the machine-readable results CI consumes.

Both are build output in `target/` and are never committed (see `.gitignore`).

## Adding a test

1. Find the feature file for the area, or create a new `.feature` file in `src/test/resources/features/`.
2. Copy the nearest scenario and change the path, method, request, and match lines.
3. Tag it (`@users`, `@auth`, `@negative`, `@smoke`) so it can be selected with `-Dkarate.tags`.
4. Run `mvn test` and read the failure in the HTML report if it goes red.

## How the pieces fit

- `KarateTest.java` is the only Java file. It is the JUnit 5 entry point and nothing else. All test logic lives in the `.feature` files.
- `karate-config.js` runs before every scenario. It sets `baseUrl` and, if `REQRES_API_KEY` (or `-Dreqres.api.key`) is set, sends it as the `x-api-key` header on every request.
- Timeouts are 10 seconds to connect and 30 seconds to read, set in `karate-config.js`. ReqRes is a fast public API; a timeout usually means the network is down, not the API.

## Known limits

- **Live API dependency.** The suite calls the real ReqRes API over the internet. It cannot run offline. A connection failure fails the run, and the report shows which step could not reach the API.
- **Shared demo key limit.** Without a personal key the suite uses the shared demo key, which has a low daily request limit. One full run is about 11 requests. If the limit is hit, runs fail with 429 statuses; set a free personal key (`REQRES_API_KEY`) as described in the README.
- **No Java code coverage.** JaCoCo is deliberately not included: the tests exercise an HTTP API, not Java code, so a Java line-coverage number would be meaningless. Coverage here is the scenario matrix above, and the Karate HTML report is the evidence.
