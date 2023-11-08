defmodule Dento.Repo.Migrations.AddUserUsernameField do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :string, collate: :nocase
    end

    create unique_index(:users, [:username])
  end
end
