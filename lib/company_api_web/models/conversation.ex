defmodule CompanyApiWeb.Conversation do
  use CompanyApiWeb, :model
  import Ecto.Query

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

  def get_conversations(id) do
    (from conv in __MODULE__,
     where: conv.sender_id == ^id)
  end
end
