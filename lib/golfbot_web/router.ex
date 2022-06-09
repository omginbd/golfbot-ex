defmodule GolfbotWeb.Router do
  use GolfbotWeb, :router

  import GolfbotWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {GolfbotWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", GolfbotWeb do
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
      pipe_through :browser
      live_dashboard "/dashboard", metrics: GolfbotWeb.Telemetry
    end
  end

  scope "/", GolfbotWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
  end

  scope "/", GolfbotWeb do
    pipe_through [:browser]

    live "/tournaments", TournamentsLive, :index
  end

  ## Unauthenticated Routes
  scope "/", GolfbotWeb do
    pipe_through [:browser]

    live "/rsvp/:token", RsvpLive, :index
    live "/leaderboard", LeaderboardLive, :index
  end

  scope "/", GolfbotWeb do
    pipe_through [:browser, :require_authenticated_user]

    delete "/users/log_out", UserSessionController, :delete

    live "/scorecard", ScorecardLive, :index
    live "/scorecard/:round_number", ScorecardLive, :index
    live "/scorecard/:round_number/:hole_number", ScorecardLive, :index
    live "/rules", RulesLive, :index
  end
end
