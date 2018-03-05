defmodule CompanyApi.Repo.Migrations.CreateUser do
  use Ecto.Migration

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
end
