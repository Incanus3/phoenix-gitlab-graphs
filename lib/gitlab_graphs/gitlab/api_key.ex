defmodule GitlabGraphs.Gitlab.ApiKey do
  use Ecto.Schema
  import Ecto.Changeset

  schema "api_keys" do
    field :name, :string
    field :server, :string
    field :key, :string, redact: true

    belongs_to :user, GitlabGraphs.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(key, attrs, user_scope) do
    key
    |> cast(attrs, [:name, :server, :key])
    |> validate_required([:name, :server, :key])
    |> put_change(:user_id, user_scope.user.id)
  end
end
