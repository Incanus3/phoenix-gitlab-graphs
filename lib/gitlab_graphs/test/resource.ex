defmodule GitlabGraphs.Test.Resource do
  use Ecto.Schema
  import Ecto.Changeset

  schema "resources" do
    field :name, :string
    field :age, :integer
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(resource, attrs, user_scope) do
    resource
    |> cast(attrs, [:name, :age])
    |> validate_required([:name, :age])
    |> put_change(:user_id, user_scope.user.id)
  end
end
