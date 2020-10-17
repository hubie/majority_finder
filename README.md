# MajorityFinder

## Quickstart

* Run
```
export LIVEVIEW_SIGNING_SALT=$(mix phx.gen.secret 32) && \
export SECRET_KEY_BASE=$(mix phx.gen.secret)` && \
iex -S mix phx.server
```
* Visit [`/vote`](http://localhost:4000/vote) to vote, [`/host`](http://localhost:4000/host) to present and control questions, and [`/results`](https://localhost:4000/results) to view the results (live!) as the votes roll in.

Ready to run in production? Please [check the Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).
