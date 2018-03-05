defmodule CompanyApiWeb.Router do
  use CompanyApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Guardian.Plug.Pipeline, module: CompanyApi.Guardian,
                                 error_handler: CompanyApi.GuardianErrorHandler
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource, ensure: true
  end

  if Mix.env == :dev do
    forward "/send_mails", Bamboo.EmailPreviewPlug
  end

  scope "/api", CompanyApiWeb do
    pipe_through :api

    resources "/users", UserController, only: [:index, :create]
    put "/users/:id", UserController, :change_password
    post "/login", SessionController, :create
  end

  scope "/api", CompanyApiWeb do
    pipe_through [:api, :auth]

    delete "/logout", SessionController, :delete
    post "/users/upload", UserController, :upload
    get "/conversations", ConversationController, :index
    post "/conversations", ConversationController, :create
    get "/messages", MessageController, :index
  end
end
