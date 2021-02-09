defmodule MajorityFinderWeb.StatsController do
  use MajorityFinderWeb, :controller

  alias Phoenix.Endpoint
  alias MajorityFinderweb.Stats

  @stats_topic MajorityFinderWeb.Stats |> to_string


  def index(conn, params) do
    player = Map.get(params, "player", "streamshark")
    render(conn, "watch.html", player: player)
    # render(conn, "watch.html")
  end

  def update(conn, %{"stats" => stats}) do
    IO.inspect(stats)
    IO.inspect(__MODULE__)

    meh = Phoenix.PubSub.broadcast(MajorityFinder.PubSub, "stats", {__MODULE__, %{update_stats: stats}})
    IO.inspect(meh)

    conn |> json(%{"response" => "ok"})
  end

end