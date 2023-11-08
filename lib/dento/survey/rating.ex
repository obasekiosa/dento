defmodule Dento.Survey.Rating do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dento.Catalog.Product
  alias Dento.Accounts.User

  schema "ratings" do
    field :stars, :integer
    # field :user_id, :id
    # field :product_id, :id
    belongs_to :user, User
    belongs_to :product, Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:stars, :user_id, :product_id])
    |> validate_required([:stars, :user_id, :product_id])
    |> validate_inclusion(:stars, 1..5)
    # |> unique_constraint([:product_id, :user_id], name: :index_ratings_on_user_product)
    |> unique_constraint(:product_id, name: :ratings_user_id_product_id_index)
  end
end
