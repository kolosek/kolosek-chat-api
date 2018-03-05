defmodule CompanyApiWeb.User do
  use CompanyApiWeb, :model
  use Arc.Ecto.Schema

  alias CompanyApi.Repo
  alias CompanyApiWeb.{ImageUpload, Conversation, Message}

  @pass_length 15

  schema "users" do
    field :name, :string
    field :subname, :string
    field :email, :string
    field :password, :string
    field :job, :string
    field :profile_image, ImageUpload.Type

    has_many :sender_conversations, Conversation, foreign_key: :sender_id
    has_many :recipient_conversations, Conversation, foreign_key: :recipient_id
    has_many :messages, Message, foreign_key: :sender_id
    timestamps()
  end

  def reg_changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:name, :subname, :email, :job, :password])
    |> validate_required([:name, :subname, :email, :job])
    |> validate_format(:email, ~r/\S+@\S+\.\S+/)
  end

  def pass_changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:name, :subname, :email, :job, :password])
    |> validate_required([:name, :subname, :email, :job, :password])
    |> validate_format(:email, ~r/\S+@\S+\.\S+/)
    |> validate_length(:password, min: 6)
  end

  def image_changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:profile_image])
    |> cast_attachments(params, [:profile_image])
  end

  def generate_password do
    :crypto.strong_rand_bytes(@pass_length)
    |> Base.encode64
    |> binary_part(0, @pass_length)
  end

  def check_registration(params) do
    case Repo.get_by(__MODULE__, params) do
      user when user != nil -> {:ok, user}
      nil -> {:error, "No user with these credentials"}
    end
  end
end
