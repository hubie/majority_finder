defmodule MajorityFinderWeb.Router do
  use MajorityFinderWeb, :router
  # alias MajorityFinderWeb.Session
  import MajorityFinderWeb.Plug.Session, only: [redirect_unauthorized: 2, validate_session: 2]

  pipeline :livebrowser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MajorityFinderWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :validate_session
    plug CORSPlug, origin: MajorityFinderWeb.Endpoint.config(:allowed_origins)
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_root_layout, {MajorityFinderWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :validate_session
    plug CORSPlug, origin: MajorityFinderWeb.Endpoint.config(:allowed_origins)
  end

  pipeline :voter do
    plug :redirect_unauthorized, resource: :voter
  end

  pipeline :admin do
    plug :redirect_unauthorized, resource: :admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MajorityFinderWeb do
    pipe_through :livebrowser

    live "/login", LoginLive, :index

  end

  scope "/", MajorityFinderWeb do
    pipe_through [:livebrowser, :admin]
    live("/results", Results)
    live("/results/:view", Results)
    live("/host", Host)
  end

  scope "/", MajorityFinderWeb do
    pipe_through [:livebrowser, :voter]

    live "/embeddedvote", EmbeddedVoteLive, :index
    live "/vote", VoterLive, :index
  end

  scope "/", MajorityFinderWeb do
    pipe_through [:browser, :voter]

    get "/", WatchController, :index
    get "/watch", WatchController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", MajorityFinderWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test, :prod] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:browser, :admin]
      live_dashboard "/dashboard", metrics: MajorityFinderWeb.Telemetry
    end
  end
end
