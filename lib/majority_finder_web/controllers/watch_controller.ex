defmodule MajorityFinderWeb.WatchController do
  use MajorityFinderWeb, :controller

  def index(conn, params) do
    player = Map.get(params, "player", "streamshark")
    render(conn, "watch.html", player: player)
    # render(conn, "watch.html")
  end
end