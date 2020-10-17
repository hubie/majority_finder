# MajorityFinder

## Quickstart

* Run
```
export MEH=$(mix phx.gen.secret 32) && \
export LOL=$(mix phx.gen.secret)` && \
iex -S mix phx.server
```
* Visit [`/vote`](http://localhost:4000/vote) to vote, [`/host`](http://localhost:4000/host) to present and control questions, and [`/results`](https://localhost:4000/results) to view the results (live!) as the votes roll in.

Ready to run in production? Please [check the Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).
