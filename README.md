# CompanyApi - Elixir api guide

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Elixir represents relatively new programming language for wider audience. It was published back in 2011, and is in development ever since. His main trait is that adops functional pardigm because it is built on top of Erlang and runs on BEAM(Erlang VM). 
Elixir is designed for building fast, scalable and maintainable applications and with Phoenix these applications can be developed in web environment. Phoenix is web framework written in Elixir and it draws a lot of concepts from popular frameworks like Python's Django or Ruby on Rails. If you are familiar with those that is a nice starting point.

# Documentation
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Elixir/Phoenix is a great combination, but before starting writing an app, those who are not familiar with all concepts should first read following documentation.
* [Elixir](https://elixir-lang.org/) - Detail documentation, from Elixir basic types to advanced stuff like Mix and OTP, 
* [Programming Elixir](https://pragprog.com/book/elixir/programming-elixir) by Dave Thomas is recommendation,
* [ExUnit](https://hexdocs.pm/ex_unit/ExUnit.html) - Built-in framework for testing,
* [Phoenix](http://phoenixframework.org/) - Phoenix framework documentation with all concepts explained with examples and
* [Ecto](https://hexdocs.pm/ecto/Ecto.html) - Docs and API for Elixir's ORM.

# Setting up application
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Elixir ships with Mix which is built-in tool that helps compiling, generating and testing application, getting dependencies etc. 
We create our application by running `mix phx.new company_api`. This tells mix to create new Phenix app named *company_api*. After running this instruction mix will create application structure:
```sh
* creating company_api/config/config.exs
* creating company_api/config/dev.exs
* creating company_api/config/prod.exs
* creating company_api/config/prod.secret.exs
* creating company_api/config/test.exs
* creating company_api/lib/company_api/application.ex
* creating company_api/lib/company_api.ex
* creating company_api/lib/company_api_web/channels/user_socket.ex
* creating company_api/lib/company_api_web/views/error_helpers.ex
* creating company_api/lib/company_api_web/views/error_view.ex
* creating company_api/lib/company_api_web/endpoint.ex
* creating company_api/lib/company_api_web/router.ex
* creating company_api/lib/company_api_web.ex
* creating company_api/mix.exs
* creating company_api/README.md
* creating company_api/test/support/channel_case.ex
* creating company_api/test/support/conn_case.ex
* creating company_api/test/test_helper.exs
* creating company_api/test/company_api_web/views/error_view_test.exs
* creating company_api/lib/company_api_web/gettext.ex
* creating company_api/priv/gettext/en/LC_MESSAGES/errors.po
* creating company_api/priv/gettext/errors.pot
* creating company_api/lib/company_api/repo.ex
* creating company_api/priv/repo/seeds.exs
* creating company_api/test/support/data_case.ex
* creating company_api/lib/company_api_web/controllers/page_controller.ex
* creating company_api/lib/company_api_web/templates/layout/app.html.eex
* creating company_api/lib/company_api_web/templates/page/index.html.eex
* creating company_api/lib/company_api_web/views/layout_view.ex
* creating company_api/lib/company_api_web/views/page_view.ex
* creating company_api/test/company_api_web/controllers/page_controller_test.exs
* creating company_api/test/company_api_web/views/layout_view_test.exs
* creating company_api/test/company_api_web/views/page_view_test.exs
* creating company_api/.gitignore
* creating company_api/assets/brunch-config.js
* creating company_api/assets/css/app.css
* creating company_api/assets/css/phoenix.css
* creating company_api/assets/js/app.js
* creating company_api/assets/js/socket.js
* creating company_api/assets/package.json
* creating company_api/assets/static/robots.txt
* creating company_api/assets/static/images/phoenix.png
* creating company_api/assets/static/favicon.ico
```
Install additional dependencies if prompted. Next we need to configure our database. In this example we used PostgreSQL, and generally Phoenix has best integration with this DBMS.

Open */config/dev.exs* and */config/test.exs* and setup username, password and database name. After setting up database, run `mix ecto.create` which will create development and test databases and after that `mix phx.server`. That should start server (Cowboy) on default port 4000. Check it up in browser, if you see landing page that's it, setup is good. All configurations are placed in */config/config.exs* file. 

# Creating API
Before coding there are several parts of development that are going to be explained:
* Writing tests using ExUnit, testing both models and controlers,
* Writing migrations,
* Writing models,
* Writing controllers,
* Routing,
* Writing views,
* Authentication using Guardian and
* Channels.

Note that following parts won't be described for whole application, but you'll get the idea. 

## Testing and writing models
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;While developing we want to write clean code that works, also think about specification and what that code needs to do before implementing it. That's why we're using [TDD](http://agiledata.org/essays/tdd.html) approach.
First in directory *test/company_api_web/* create models directory and then create user_test.exs. After that create a module: 
```elixir
defmodule CompanyApiWeb.UserTest do
    use CompanyApi.DataCase, async: true
end
```
On second line, we use macro *use* to inject some external code, in this case data_case.exs script that is placed in *test/support/* directory among other scipts and `async: true` to mark that this test will run asynchronous with other tests. But be careful, if test writes data to database or in some sense changes some data then it should not run asyc.

Think of what should be tested. In this case let's test creating user with valid and invalid data. Some mock up data can be set via module attributes as constants, for example:
```elixir
@valid_attributes %{name:    "John",
                    subname: "Doe",
                    email:   "doe@gmail.com",
                    job:     "engineer"
                   }
```
Ofcourse you don't have to use module attributes but it makes code cleaner. Next let's write test.
```  elixir
test "user with valid attributes" do
  user = CompanyApiWeb.User.reg_changeset(%User{}, @valid_attributes)

  assert user.valid?
end
```
  In this test we try to create [changeset](https://hexdocs.pm/ecto/Ecto.Changeset.html) by calling method *reg_changeset/2* and then asserting for true value. 
If we run this test with `mix test test/company_api_web/models/user_test.exs`, test will fail ofcourse. First we dont even have User module, but we dont even have User table in database. Next we need to write a migration. `mix ecto.gen.migration create_user` generates migration in *priv/repo/migrations/*. There we define function for table creation in sugar elixir syntax which then translates into appropriate SQL query.
```elixir
def change do
  create table(:users) do
    add :name, :varchar
    add :subname, :varchar
    add :email, :varchar
    add :job, :varchar
    add :password, :varchar

    timestamps()
  end
end
  ```
  Function *create/2* creates database table from struct returned by function *table/2*. For detail information about field type, options, and creating indexes read docs. By default surrogate key is generated for every table, with name id and type integer, if not defined otherwise.
  
Now we run command `mix ecto.migrate` which runs migration. Next we need to create model, so create models directory in *lib/company_api_web/* and create user.ex file. Our model is used to represent data from database tables as it maps that data into Elixir structs.
```elixir
defmodule CompanyApiWeb.User do
  use CompanyApiWeb, :model

  schema "users" do
    field :name, :string
    field :subname, :string
    field :email, :string
    field :password, :string
    field :job, :string
  end
  
  def reg_changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:name, :subname, :email, :job, :password])
    |> validate_required([:name, :subname, :email, :job])
    |> validate_format(:email, ~r/\S+@\S+\.\S+/)
  end
end
```
On line 2, we use helper defined in *lib/company_api_web/company_api_web.ex* which actually imports all necessary modules for creating models. If you open file you'll see that model is actually a function, same as controller, view, channel, router etc. (If there is no model function you can add it yourself).
  
Two important methods are schema (table <-> struct mapping) and *changeset/2*. Changeset functions are not necessary, but are Elixir's way of creating structs that modify database. We can define one for registration, login etc. All validation and association checking can be done before we even try inserting data into database. For more details check *Ecto.Changeset* docs. If we now run test again, it should pass. Add as many test cases as you want and try to cover all edge cases. 
This should wrap creation of simple models. Adding association is going to be mention earlier. 

## Testing and writing controllers
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Testing controllers is equally important as testing models. We are going to test registration of new user and getting all registered users in a system. Again we create test, this time in *test/company_api_web/controllers/* with name user_controller_test.exs. With controller testing we're going to use conn_case.exs script. Another important thing about test that wasn't mention while testing models (cause we didn't need it) is setup block. 
```elixir
setup do
  user =
    %User{}
    |> User.reg_changeset(@user)
    |> Repo.insert!

  conn =
    build_conn()
    |> put_req_header("accept", "application/json")

  %{conn: conn, user: user}
end
```
Setup block is called before invokation of each test case, and in this block we prepare data for tests. We can return data from block in a form of tuple or map. In this block we will insert one user into database and create connection struct which is mockup of connection. Again constants can be used to setup data. 
```elixir
@valid_data %{name:    "Jim",
              subname: "Doe",
              email:   "doe@gmail.com",
              job:     "CEO"
             }

@user %{name:    "John",
        subname: "Doe",
        email:   "doe@gmail.com",
        job:     "engineer"
       }

@user_jane %{name:    "Jane",
             subname: "Doe",
             email:   "jane@gmail.com",
             job:     "architect"
            }
```
Now let's write test that sends request for creating new user. Server should process request, generate password, create new user, send email with generated password and return user as a json. That sounds like a lot, but we'll go slow. Pay attention that you should try to cover all 'paths' and edge cases. First let's test with valid data, and then with invalid data.
```elixir
describe "tries to create and render" do
  test "user with valid data", %{conn: conn} do
    response =
      post(conn, user_path(conn, :create), user: @valid_data)
      |> json_response(201)

    assert Repo.get_by(User, name: "Jim")
    assert_delivered_email Email.create_mail(response["password"], response["email"])
  end

  test "user with invalid data", %{conn: conn} do
    response =
      post(conn, user_path(conn, :create), user: %{})
      |> json_response(422)

    assert response["errors"] != %{}
  end
end
```
Each test sends post request to certain path and then we check json response and assert value. Running this test with `mix test test/company_api_web/controller/user_controller_test.exs` will result in errors. We don't have *user_path/3* function which means that route isn't defined. Open *lib/company_api_web/router.ex*. We'll add scope "/api" which will go through :api pipeline. We can define routes as resources, individually or as nested routes. Define new resource like this:
`resources "/users", UserController, only: [:index, :create]`

With this, Phoenix creates routes which are mapped to index and create functions and handled by UserController. If you open console and type `mix phx.routes` you can see list of routes and there are *user_path* routes, one with verb GET and one with verb POST. Now if we run test again, this time we'll get another error, create function missing. Reason for this is that we don't have UserController. Add user_controller.ex in *lib/company_api_web/controllers*. Now define new module:
```elixir
defmodule CompanyApiWeb.UserController do
  use CompanyApiWeb, :controller
end
```
Next we need to create that *create/2* function. Create function must accept conn struct(and also return it) and params. Params is struct which carries all data supplied by browser. We can use one powerful feature of Elixir, pattern matching, to match just the data we need with our variables.
```elixir
def create(conn, %{"user" => user_data}) do
  params = Map.put(user_data, "password", User.generate_password())
  case Repo.insert(User.reg_changeset(%User{}, params)) do
    {:ok, user} ->
      conn
      |> put_status(:created)
      |> render("create.json", user: user)
    {:error, user} ->
      conn
      |> put_status(:unprocessable_entity)
      |> render("error.json", user: user)
  end
end
```
In our tests we send through post method params *user: @valid_data*, and that data is going to be matched with *user_data*. In User model define *generate_password* function, so we can generate random passwords for every new user.
```elixir
 def generate_password do
    :crypto.strong_rand_bytes(@pass_length)
    |> Base.encode64
    |> binary_part(0, @pass_length)
  end
```
Set the length of a password as you wish. Since the user_data is a map we are going to put new generated password inside that map with key "password". 
Although Elixir has try/rescue blocks they are rarely used. Usually combination of case and pattern matching is used for error handling. Function insert(note that we won't use insert! function cause it raises exception) returns one of two tuples:
```elixir
{:ok, Ecto.Schema.t}
{:error, Ecto.Changeset.t}
```
Based on returned tuple we send appropriate response. Since we're making JSON API, we should return data in json format. All data returned from controller is handled by appropriate view. If we run tests again, we are going to get another error. Last thing we need to do is to add view file. Create user_view.ex file in *lib/company_api_web/views/* and inside define new module and render methods.
```elixir
defmodule CompanyApiWeb.UserView do
  use CompanyApiWeb, :view
  
  def render("create.json", %{user: user}) do
   render_one(user, CompanyApiWeb.UserView, "user.json")
  end
  
  def render("error.json", %{user: user}) do
    %{errors: translate_errors(user)}
  end
  
  def render("user.json", %{user: user}) do
    %{id: user.id, 
      name: user.name, 
      subname: user.subname, 
      password: user.password, 
      email: user.email, 
      job: user.job}
  end
  
  defp translate_errors(user) do
    Ecto.Changeset.traverse_errors(user, &translate_error/1)
  end
end
```
First render method is being called from controller, and in that method we call *render_one/3* to which we pass key, view module, and template name, so we can pattern match method. Now we return data which is going to be encoded into json. We didn't have to call *render_one/3* method, we could return json right away, but this is more convinient. 

Second render method renders errors provided by changeset struct in form of json. Built-in method *Ecto.Changeset.traverse_errors/2* extracts error strings from changeset.errors struct.
If we remove that one line which asserts that email has been sent, our tests will pass. This rounds up how we test and write controllers. Now you can test and write index method and add more test cases that covers more code.

## Email sending example
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;There are several email libraries in Elixir, but in this project we decided to use [Bamboo](https://github.com/thoughtbot/bamboo). After initial setup, its usage is fairly easy.  Open *mix.exs* file and under deps function add following line:
`{:bamboo, "~> 0.8"}`
and then run following command:
`mix deps.get`
which will download dependency. After that add bamboo as extra_application in *application* function. In global config file add configuration for Bamboo:
```elixir
config :company_api, CompanyApi.Mailer,
  adapter: Bamboo.LocalAdapter
```
Here we're using Bamboo.LocalAdapter but there are other adapters also. Now, create module CompanyApi.Mailer and following line:
`use Bamboo.Mailer, otp_app: :company_api`
Before using mailer we should define email struct. Add into models directory Email.ex file(Note that you should first write test then add file but we'll skip that now).
```elixir
defmodule CompanyApiWeb.Email do
  import Bamboo.Email

  def create_mail(password, email) do
    new_email()
    |> to(email)
    |> from("company@gmail.com")
    |> subject("Generated password")
    |> html_body("<h1>Welcome to Chat</h1>")
    |> text_body("Welcome. This is your generated password #{password}. You can change it anytime.")
  end
end
```
Function *create_mail/2* returns email struct which we will use for sending. Before running tests we need to add configuration in */config/test.exs*, same as before, only difference is in adapter which is now, Bamboo.TestAdapter. Adding this `use Bamboo.Test` allows as to use function such as `assert_delivered_email` in our tests. Now in UserController after successfull insert add next line:
```elixir
Email.create_mail(user.password, user.email)
|> CompanyApi.Mailer.deliver_later
```
This is going to create email struct and send it in the background. For asynchronuos sending there is [Task](https://hexdocs.pm/elixir/Task.html) module. If you wish to see sent mails, in *router.exs* add following:
```elixir
if Mix.env == :dev do
  forward "/send_mails", Bamboo.EmailPreviewPlug
end
```
Now we can see delivered mails at *localhost:4000/sent_mails*.

##Authentication via Guardian
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;So far we've have shown how to write tests, migrations, models, controllers, views and routing. One more important thing is authenticating user. Library of choice here was [Guardian](https://github.com/ueberauth/guardian). It uses JWT (Json Web Token) as a method of authentication and we can authenticate Phoenix services and also channels. Great stuff. 

First add dependency `{:guardian, "~> 1.0-beta"}` in mix.exs file and run `mix deps.get`. In Guardian docs there is detail explanation how to setup basic configuration, but we're going to go step by step here. Open */config/config.exs* and add following:
```elixir
config :company_api, CompanyApi.Guardian,
  issuer: "CompanyApi",
  secret_key: "QDG1lCBdCdjwF49UniOpbxgUINhdyvQDcFQUQam+65O4f9DgWRe09BYMEEDU1i9X",
  verify_issuer: true
```
Note that CompanyApi.Guardian is going to be module that we're going to create. You don't have to call it Guardian, maybe it's little redundant. Anyway, next thing is secret_key that has to be generated. This is example of one secret key, and it can be generated by running 
`mix guardian.gen.secret`. Create CompanyApi.Guardian module in *lib/company_api/*.
```elixir
defmodule CompanyApi.Guardian do
  use Guardian, otp_app: :company_api

  alias CompanyApi.Repo
  alias CompanyApiWeb.User

  def subject_for_token(user = %User{}, _claims) do
    {:ok, "User:#{user.id}"}
  end

  def subject_for_token(_) do
    {:error, "Unknown type"}
  end

  def resource_from_claims(claims) do
    id = Enum.at(String.split(claims["sub"], ":"), 1)
    case Repo.get(User, String.to_integer(id)) do
      nil  ->
        {:error, "Unknown type"}
      user ->
        {:ok, user}
    end
  end
end
```
This module is going to be used when token is being created. We've put user id as a subject for token, in that way we can always get user from database. This may be the most convinient way, but it's not the only way. Next thing we're going to do is to set up guardian pipeline. Using Guardian with plugs is easy. Open *lib/company_api_web/router.ex* and add new pipeline:
```elixir
pipeline :auth do
    plug Guardian.Plug.Pipeline, module: CompanyApi.Guardian,
                                 error_handler: CompanyApi.GuardianErrorHandler
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource, ensure: true
  end
```
This pipeline can be defined directly in router.ex file, or can be defined in separate module, but still needs to be referenced here. When user tries to call some service his request is going to pass through pipeline. Note that this pipeline is specifically for **JSON API**. 

Okey, first we define that we're using plug pipeline and reference implementation module and module that is going to handle auth errors (we're going to create it). Next plug verifies that token is in request header,plug EnsureAuthenticated ensures that valid JWT token was provided and last plug loads resource by calling function *resource_from_claims/1* specified in CompanyApi.Guardian module. 
Since we're missing auth_error handling module add it in *lib/company_api/*.
```elixir
defmodule CompanyApi.GuardianErrorHandler do
  def auth_error(conn, {_type, reason}, _opts) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(401, Poison.encode!(%{message: to_string(reason)}))
  end
end
```
[Poison](https://github.com/devinus/poison) is Elixir JSON library. Just add dependency `{:poison, "~> 3.1"}` in mix.exs.
We've set up everything for Guardian and now it's time to write SessionController and handle login and logout. First we have to write tests. Create session_controller_test.exs. We're going to test user login and make it pass. We've already wrote tests for UserController so you know how to set up this one also. 
```elixir
  test "login as user", %{conn: conn, user: user} do
    user_credentials = %{email: user.email, password: user.password}
    response =
      post(conn, session_path(conn, :create), creds: user_credentials)
      |> json_response(200)

    expected = %{
      "id"        => user.id,
      "name"      => user.name,
      "subname"   => user.subname,
      "password"  => user.password,
      "email"     => user.email,
      "job"       => user.job
    }

    assert response["data"]["user"]   == expected
    refute response["data"]["token"]  == nil
    refute response["data"]["expire"] == nil
  end
```
We're going to try to login with valid credentials and we expect to get as a response user, token and expire value. If we run this test, it is going to fail. We don't have *session_path* route. Open router.ex file and in our "/api" scope add new route:
`post "/login", SessionController, :create`
We've put this route in "/api" scope becase our user doesn't need to get authenticated while he's trying to login. If we run test again, this time it is going to fail becase there is no create function. 
Let's add SessionController now and write login function.
```elixir
 def create(conn, %{"creds" => params}) do
    new_params = Map.new(params, fn {k, v} -> {String.to_atom(k), v} end)
    case User.check_registration(new_params) do
      {:ok, user} ->
        new_conn = Guardian.Plug.sign_in(conn, CompanyApi.Guardian, user)
        token    = Guardian.Plug.current_token(new_conn)
        claims   = Guardian.Plug.current_claims(new_conn)
        expire   = Map.get(claims, "exp")

        new_conn
        |> put_resp_header("authorization", "Bearer #{token}")
        |> put_status(:ok)
        |> render("login.json", user: user, token: token, exp: expire)
      {:error, reason} ->
        conn
        |> put_status(401)
        |> render("error.json", message: reason)
    end
  end
```
First line creates new map as a result with keys as atoms. Function *check_registration/1* checks if user with given credentials exist in database. If user exists we sign him in, create new token and expire date. After that we set response header, status and render user. For rendering we need to create session_view.ex in *lib/company_api_web/views/*.
```elixir
defmodule CompanyApiWeb.SessionView do
  use CompanyApiWeb, :view

  def render("login.json", %{user: user, token: token, exp: expire})  do
    %{
      data: %{
        user:   render_one(user, CompanyApiWeb.UserView, "user.json"),
        token:  token,
        expire: expire
      }
    }
  end
  
  def render("error.json", %{message: reason}) do
    %{data: reason}
  end
end
```
Now test should pass. Ofcourse more tests should be added, but that's up to you. Logout is fairly simple, `Guardian.revoke(CompanyApi.Guardian, token)` deletes token from header and that is all we need to do. With APIs there is no really logout, but this will work. Before adding new route for logging out, we need to define "new scope". Actually this is going to be the same "/api" scope again, but it will go through two pipelines now: `pipe_through [:api, :auth]`. 

Why are we doing this? Every new route that needs to be authenticated will be places inside of this new scope. Also if we want to logout, we need to be authenticated first. With this we've covered authenticating with Guardian. Later socket authentication is going to be mentioned, and it's even easier.

## Associations example
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Since this is a chat app, message history has to be saved somehow. We're going to add two more entities that will represent conversation between two users and user's messages. This will be a good opportunity to show examples of associations in Ecto.

First entity that we're going to add is conversation entity. Conversations will belong to both user involved in chat, and user is going to have many conversations. Also conversations will have many messages which is second entity. Messages will belong to user and certian conversation. In this case user represents a person who sends messages. Other attributes of message are date and content. 
In a few sentences we've described our data model. Each of these data models will have their own tests, controllers and views, but since we've explained all of these stuff already, in this part we're going to focus on associations between these entities. Note that the only thing you need to do is to write function for creation of conversation, creation of messages and getting message history.

### Conversations
Firstly, lets add conversations migration. 
Run command `mix ecto.gen.migration create_conversations`. Now we need to create table conversations with correct columns:
```elixir
  def change do
    create table(:conversations) do
      add :sender_id, references(:users, null: false)
      add :recipient_id, references(:users, null: false)

      timestamps()
    end

    create unique_index(:conversations, [:sender_id, :recipient_id], name: :sender)
  end
```
As you can see, we're adding foreign keys sender_id and recipient_id and we are referencing users table. This will represent our two users in conversation. Both keys can't be null. Last thing we want to do is to create unique_index on both columns which correspond to unique constraint. We're doing this because we don't want duplicate conversations with the same ids. Lets create model now:
```elixir
defmodule CompanyApiWeb.Conversation do
  use CompanyApiWeb, :model

  alias CompanyApiWeb.{User, Message}

  schema "conversations" do
    field :status, :string

    belongs_to :sender, User, foreign_key: :sender_id
    belongs_to :recipient, User, foreign_key: :recipient_id
    has_many :messages, Message

    timestamps()
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:sender_id, :recipient_id, :status])
    |> validate_required([:sender_id, :recipient_id])
    |> unique_constraint(:sender_id, name: :sender)
    |> foreign_key_constraint(:sender_id)
    |> foreign_key_constraint(:recipient_id)
  end
```
Observe new functions. Functions *belongs_to/3* and *has_many/3* represents associations. Usually *belongs_to/3* function is defined with a name and a referenced module, but this time since we're have two references to the same module we have to add a correspond foreign key column. Same story goes for *has_many/3* association, association name and module(we're going to create Message module soon). Now the changeset. We've added two *foreign_key_contraint/3* functions, one for each foreign key and *unique_constraint/3* function (because of composite unique columns, only one has to specified). All of these contraints are checked on database level.

### Mesages
Second entity is messages. Run `mix ecto.gen.migration create_messages`. Add create and table functions:
```elixir
  def change do
    create table(:messages) do
      add :sender_id, references(:users, null: false)
      add :conversation_id, references(:conversations, null: false)
      add :content, :varchar
      add :date, :naive_datetime

      timestamps()
    end

    create index(:messages, [:sender_id])
    create index(:messages, [:conversation_id])
  end
```
Same story as before. Two foreign keys, messages belong to user (sender) and conversation. This time we don't need unique contraint, so we just index mentioned fields. One look at the model:
```elixir
defmodule CompanyApiWeb.Message do
  use CompanyApiWeb, :model
  
  alias CompanyApiWeb.{User, Conversation}

  schema "messages" do
    field :content, :string
    field :date, :naive_datetime

    belongs_to :conversation, Conversation
    belongs_to :sender, User, foreign_key: :sender_id

    timestamps()
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:sender_id, :conversation_id, :content, :date])
    |> validate_required([:sender_id, :conversation_id, :content, :date])
    |> foreign_key_constraint(:sender_id)
    |> foreign_key_constraint(:conversation_id)
  end
```
Last thing we need to do is to add associations in User module:
```elixir
 has_many :sender_conversations, Conversation, foreign_key: :sender_id
 has_many :recipient_conversations, Conversation, foreign_key: :recipient_id
 has_many :messages, Message, foreign_key: :sender_id
```
With this we've set up our data model and you've seen brief example of Ecto associations. For many_to_many association read [docs](https://hexdocs.pm/ecto/Ecto.Schema.html#many_to_many/3).

## Channels
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Essentially channels are Phoenix abstraction build on top of sockets. It is possible to have multiple channels over one socket connection. For detail explanations and understanding how channels recommendation is to read [official documentation](https://hexdocs.pm/phoenix/channels.html).

Our goal is to send message via Websocket protocol, and we're going to start with writing channel tests. [Documentation](https://hexdocs.pm/phoenix/testing_channels.html#content) on channel testing is really helpful. 
Create chat_room_test.exs in */test/company_api_web/channels/* directory. In setup block insert one user into database, create connection and sign in user. We're going to test message sending.
```elixir
defmodule CompanyApiWeb.ChatRoomTest do
  use CompanyApiWeb.ChannelCase

  alias CompanyApi.Guardian, as: Guard
  alias CompanyApiWeb.{ChatRoom, UserSocket, Conversation}

  @first_user_data %{ name:    "John",
                      subname: "Doe",
                      email:   "doe@gmail.com",
                      job:     "engineer"
                    }

  @second_user_data %{ name:    "Jane",
                       subname: "Doe",
                       email:   "jane@gmail.com",
                       job:     "architect"
                     }

  setup do
    user =
      %User{}
      |> User.reg_changeset(@first_user_data)
      |> Repo.insert!

    {:ok, token, _claims} = Guard.encode_and_sign(user)

    {:ok, soc} = connect(UserSocket, %{"token" => token})
    {:ok, _, socket} = subscribe_and_join(soc, ChatRoom, "room:chat")

    {:ok, socket: socket, user: user}
  end

  test "checks messaging", %{socket: socket, user: u} do
    user =
      %User{}
      |> User.reg_changeset(@second_user_data)
      |> Repo.insert!

    conv =
      %Conversation{}
      |> Conversation.changeset(%{sender_id: u.id, recipient_id: user.id})
      |> Repo.insert!

    {:ok, token, _claims} = Guard.encode_and_sign(user)
    {:ok, soc} = connect(UserSocket, %{"token" => token})

    {:ok, _, socketz} = subscribe_and_join(soc, ChatRoom, "room:chat")

    push socket, "send_msg", %{user: user.id, conv: conv.id, message: "Hi! This is message"}
    assert_push "receive_msg", %{message: message}
    assert message.content == "Hi! This is message"
    refute Repo.get!(CompanyApiWeb.Message, message.id) == nil

    push socketz, "send_msg", %{user: u.id, conv: conv.id, message: "This is a reply"}
    assert_push "receive_msg", %{message: reply}
    assert reply.content == "This is a reply"
    refute Repo.get!(CompanyApiWeb.Message, reply.id) == nil
  end
end
```
Well, this seem like a lot, but lets go step by step. In setup block we connect to socket with generated token, and then function *subscribe_and_join/3* joins user to listed topic. After that in test, those steps are repeated for second user and then conversation is created. Function *push/3* allows us to send messages directly through socket while *assert_push* or *assert_broadcast* asserts for pushed or broadcasted messages. Running test is goint to result in errors. 

Open *lib/company_api_web/channels/user_socket.ex* and define new channel 
`channel "room:*", CompanyApiWeb.ChatRoom`.
While here modify *connect/2* and *id/1* functions. We want to make that only authenticated users can connect to socket.
```elixir
def connect(%{"token" => token}, socket) do
    case Guardian.Phoenix.Socket.authenticate(socket, CompanyApi.Guardian, token) do
      {:ok, socket} ->
        {:ok, socket}
      {:error, _} ->
        :error
    end
  end

  def connect(_params, _socket), do: :error

  def id(socket) do
    user = Guardian.Phoenix.Socket.current_resource(socket)
    "user_socket:#{user.id}"
  end
```
Line `Guardian.Phoenix.Socket.authenticate(socket, CompanyApi.Guardian, token)` provides authentication. Function *id/1* returns socket id, and we set it as a user id.

Now lets create new channel. In the same directory create channel_room.ex file, but for now leave it be. Since we are making private chat we need to know socket we are sending messages to. There are some ways of achieving that. Decision here was to store opened socket connections in a map 
`{user_id: socket}`. Elixir provides two abstractions for storing state, [GenServers](https://hexdocs.pm/elixir/GenServer.html) and [Agent](https://hexdocs.pm/elixir/Agent.html#content). For understanding concepts of GenServer or Agent documentation has to be read. 

Open *lib/company_api/* and create channel_sessions.ex, this will be our GenServer for storing sockets. 
```elixir
defmodule CompanyApi.ChannelSessions do
  use GenServer

  #Client side

  def start_link(init_state) do
    GenServer.start_link(__MODULE__, init_state, name: __MODULE__)
  end

  def save_socket(user_id, socket) do
    GenServer.call(__MODULE__, {:save_socket, user_id, socket})
  end

  def delete_socket(user_id) do
    GenServer.call(__MODULE__, {:delete_socket, user_id})
  end

  def get_socket(user_id) do
    GenServer.call(__MODULE__, {:get_socket, user_id})
  end

  def clear() do
    GenServer.call(__MODULE__, :clear)
  end

  #Server callbacks

  def handle_call({:save_socket, user_id, socket}, _from, socket_map) do
    case Map.has_key?(socket_map, user_id) do
      true ->
        {:reply, socket_map, socket_map}
      false ->
        new_state = Map.put(socket_map, user_id, socket)
        {:reply, new_state, new_state}
    end
  end

  def handle_call({:delete_socket, user_id}, _from, socket_map) do
    new_state = Map.delete(socket_map, user_id)

    {:reply, new_state, new_state}
  end

  def handle_call({:get_socket, user_id}, _from, socket_map) do
    socket = Map.get(socket_map, user_id)

    {:reply, socket, socket_map}
  end

  def handle_call(:clear, _from, state) do
    {:reply, %{}, %{}}
  end
end
```
GenServer abstracts common client-server interaction. Client side calls server-side callbacks. These callbacks conduct opereations over map. This module should start when application starts, so we'll add it in [Supervision tree](https://hexdocs.pm/elixir/Supervisor.html#content). This is one of most beautiful things in Elixir. 

Open application.ex file in the same directory and add this line `worker(CompanyApi.ChannelSessions, [%{}])` in children list. This will start ChannelSessions at the start of the application with inital state `%{}`. Now we can write ChatRoom channel. Every channel has to implement two callbacks *join/3* and *handle_in/3*.
```elixir
defmodule CompanyApiWeb.ChatRoom do
  use CompanyApiWeb, :channel

  alias CompanyApi.{ChannelSessions, ChannelUsers}
  alias CompanyApiWeb.Message

  def join("room:chat", _payload, socket) do
    user = Guardian.Phoenix.Socket.current_resource(socket)
    send(self(), {:after_join, user})

    {:ok, socket}
  end

  def handle_in("send_msg", %{"user" => id, "conv" => conv_id, "message" => content}, socket) do
    case ChannelSessions.get_socket id do
      nil ->
        {:error, socket}
      socketz ->
        user = Guardian.Phoenix.Socket.current_resource(socket)
        case Message.create_message(user.id, conv_id, content) do
          nil ->
            {:noreply, socket}
          message ->
            push socketz, "receive_msg", %{message: message}
            {:noreply, socket}
        end
    end
  end

  def handle_info({:after_join, user}, socket) do
    ChannelSessions.save_socket(user.id, socket)

    {:noreply, socket}
  end

  def terminate(_msg, socket) do
    user = Guardian.Phoenix.Socket.current_resource(socket)
    ChannelSessions.delete_socket user.id
  end
end
```
Since we need to save socket, it can be only done after socket is created which is at the end of *join/3* callback. For that reason we send message to ourself which is going to call callback method *handle_info/2*. There we add socket into the map. Callback *handle_in/3* creates a message and sends it to appropriate user. Function *teminate/2* removes socket from map.

With this being set, chat app API has been finished. This tutorial covers all listed parts from earlier with some advanced stuff from [OTP](http://learnyousomeerlang.com/what-is-otp) like GenServer. It aims to show workflow while developing one Elixir application, and for complete understanding requires documentation reading. After all, there are all informations. Recommended place for all Elixir enthusiasts, [Elixir Forum](https://elixirforum.com/).













