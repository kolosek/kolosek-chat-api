defmodule CompanyApiWeb.UserController do
  use CompanyApiWeb, :controller

  alias CompanyApiWeb.{User, Email}

  def index(conn, _params) do
    users = Repo.all(User)

    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_data}) do
    params = Map.put(user_data, "password", User.generate_password())
    case Repo.insert(User.reg_changeset(%User{}, params)) do
      {:ok, user} ->
        spawn(fn() ->
          Task.Supervisor.start_child(EmailSupervisor, fn() ->
            Email.create_mail(user.password, user.email)
            |> CompanyApi.Mailer.deliver_later
          end)
        end)

        conn
        |> put_status(:created)
        |> render("create.json", user: user)
      {:error, user} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", user: user)
    end
  end

  def change_password(conn, %{"id" => id, "password" => new_password}) do
    user =
      case Repo.get(User, id) do
        nil -> %User{}
        user -> user
      end
    user_pass = User.pass_changeset(user, %{password: new_password})

    case Repo.update(user_pass) do
      {:ok, user} ->
        conn
        |> put_status(:ok)
        |> render("password.json", pass: user.password)
      {:error, user} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", user: user)
    end
  end

  def upload(conn, %{"image" => profile_image}) do
    logged_user = CompanyApi.Guardian.Plug.current_resource(conn)
    user = Repo.get(User, logged_user.id)
    changeset =
      user
      |> User.image_changeset(%{profile_image: profile_image})

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_status(:ok)
        |> render("upload.json", user: user)
      {:error, user} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", user: user)
    end
  end
end
