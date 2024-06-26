defmodule HouseWeb.Router do
  use HouseWeb, :router

  import HouseWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HouseWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HouseWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", HouseWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:house, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HouseWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", HouseWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{HouseWeb.UserAuth, :redirect_if_user_is_authenticated},{HouseWeb.PreparePathData, :prepare_path_data}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", HouseWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{HouseWeb.UserAuth, :ensure_authenticated},{HouseWeb.PreparePathData, :prepare_path_data}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      live "/warehouses", WarehouseLive.Index, :index
      live "/warehouses/new", WarehouseLive.Index, :new
      live "/warehouses/:warehouse_id/edit", WarehouseLive.Index, :edit

      live "/warehouses/:warehouse_id", WarehouseLive.Show, :show
      live "/warehouses/:warehouse_id/show/edit", WarehouseLive.Show, :edit

      scope "/warehouses/:warehouse_id" do
        live "/products", ProductLive.Index, :index
        live "/products/new", ProductLive.Index, :new
        live "/products/:product_id/edit", ProductLive.Index, :edit

        live "/products/:product_id", ProductLive.Show, :show
        live "/products/:product_id/show/edit", ProductLive.Show, :edit
      end

      live "/members", MemberLive.Index, :index
      live "/members/new", MemberLive.Index, :new
      live "/members/:id/edit", MemberLive.Index, :edit

      live "/members/:id", MemberLive.Show, :show
      live "/members/:id/show/edit", MemberLive.Show, :edit
    end
  end

  scope "/", HouseWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{HouseWeb.UserAuth, :mount_current_user},{HouseWeb.PreparePathData, :prepare_path_data}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
