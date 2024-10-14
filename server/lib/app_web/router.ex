defmodule AppWeb.Router do
  use AppWeb, :router

  import AppWeb.Plugs.Authorization,
    only: [
      require_authenticated: 2
    ]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :put_root_layout, html: {AppWeb.Layouts, :root}
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: AppWeb.ApiSpec
  end

  pipeline :protected_api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: AppWeb.ApiSpec
    plug :require_authenticated
  end

  scope "/api" do
    pipe_through :api
    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end

  scope "/api", AppWeb.Auth do
    pipe_through :api

    post "/users/register", UserRegistrationController, :create
    post "/users/confirm", UserConfirmationController, :create
    post "/users/confirm/:token", UserConfirmationController, :update
    post "/users/reset_password", UserResetPasswordController, :create
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/api", AppWeb.Accounts do
    pipe_through :protected_api

    get "/users/settings", UserSettingsController, :show
    put "/users/settings", UserSettingsController, :update
    post "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/oauth", AppWeb.Oauth do
    pipe_through :api

    post "/revoke", RevokeController, :revoke
    post "/token", TokenController, :token
    post "/introspect", IntrospectController, :introspect
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:app, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/" do
    pipe_through :browser

    get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
    get "/*path", AppWeb.PageController, :index
  end
end
