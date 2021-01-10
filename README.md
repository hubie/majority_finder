# MajorityFinder

## Quickstart

### Run
```
export LIVEVIEW_SIGNING_SALT=$(mix phx.gen.secret 32) && \
export SECRET_KEY_BASE=$(mix phx.gen.secret)` && \
iex -S mix phx.server
```
* Visit [`/vote`](http://localhost:4000/vote) to vote, [`/host`](http://localhost:4000/host) to present and control questions, and [`/results`](https://localhost:4000/results) to view the results (live!) as the votes roll in.


## Deploying
* Create `ALLOWED_ORIGINS` environment variable with the URLS that requests will be coming from, e.g. `https://example.com,https://vote.example.com` (defaults to `localhost`, `127.0.0.1`)

### Access Codes
* Create a Google API Service Account to connect MajorityFinder to the Google Sheet
** Follow [this Google API wizard](https://console.developers.google.com/flows/enableapi) to create an API client that can access the sheet.
*** Which API are you using? google Sheets API
*** Where will you be be calling the API from? Web server
*** What data will you be accessing? Application data
*** Are you planning to use this APi with App engine or Compute Engine? No

*** Create Service Account: Role: Editor (for recording results) Viewer (For access codes only)
*** Key type: JSON
*** Note the Email in address created for your API Service Account.  This will look something like `my-cool-app@leroy-jenkins-301201.iam.gserviceaccount.com`
*** A JSON key will be created for your API Service Account

* Create a `GOOGLE_SERVICE_KEY` environment variable with the contents of the JSON API key

* Create Google Sheet with the events Login Codes
** Share the sheet to the email address of the API Service Account created earlier
** Create a `VOTER_CODE_SHEET_ID` environment variable with the Sheet ID
*** For a Sheet URL like `https://docs.google.com/spreadsheets/d/1yY-AXyuJM09OFm6irwgyfg6haQmVUVnDC7ObjYRi-fU/edit#gid=0`, the Sheet ID would be `1yY-AXyuJM09OFm6irwgyfg6haQmVUVnDC7ObjYRi-fU`, the part following `/d/` and before `/edit`


Ready to run in production? Please [check the Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).

