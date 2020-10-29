defmodule MajorityFinderWeb.WatchController do
  use MajorityFinderWeb, :controller

  def index(conn, _params) do
    render(conn, "watch.html", %{})
    # render(conn, "watch.html")
  end
end