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
