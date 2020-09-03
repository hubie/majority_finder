defmodule MajorityFinderWeb.Router do
  use MajorityFinderWeb, :router
  # alias MajorityFinderWeb.Session
  import MajorityFinderWeb.Plug.Session, only: [redirect_unauthorized: 2, validate_session: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MajorityFinderWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :validate_session
  end

  pipeline :restricted do
    plug :browser
    plug :redirect_unauthorized, roles: [:admin, :voter]
  end

  pipeline :admin do
    plug :browser
    plug :redirect_unauthorized, roles: [:admin]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MajorityFinderWeb do
    pipe_through :browser

    live "/login", LoginLive, :index

    live "/", PageLive, :index
  end

  scope "/", MajorityFinderWeb do
    pipe_through :admin
    live("/results", Results)
    live("/host", Host)
  end

  scope "/vote", MajorityFinderWeb do
    pipe_through :restricted

    live "/", VoterLive, :index
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
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :restricted
      live_dashboard "/dashboard", metrics: MajorityFinderWeb.Telemetry
    end
  end
end
