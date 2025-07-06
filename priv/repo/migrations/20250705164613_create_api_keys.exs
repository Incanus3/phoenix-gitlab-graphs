defmodule GitlabGraphs.Repo.Migrations.CreateApiKeys do
  use Ecto.Migration

  def change do
    create table(:api_keys) do
      add :name, :string, null: false
      add :server, :string, null: false
      add :key, :string, null: false
      add :user_id, references(:users, type: :id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:api_keys, [:user_id])
  end
end
