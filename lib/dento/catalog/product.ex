defmodule Dento.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dento.Catalog.Product
  alias Dento.Survey.Rating

  schema "products" do
    field :name, :string
    field :description, :string
    field :unit_price, :float
    field :sku, :integer
    field :image_upload, :string

    timestamps(type: :utc_datetime)
    has_many :ratings, Rating
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :unit_price, :sku, :image_upload])
    |> validate_product()
  end

  def validate_product(changeset) do
    changeset
    |> validate_required([:name, :description, :unit_price, :sku])
    |> unsafe_validate_unique(:sku, Dento.Repo)
    |> unique_constraint(:sku)
    |> validate_number(:unit_price, greater_than: 0.0)
  end

  def unit_price_changeset(%Product{unit_price: org_price}=product, %{unit_price: new_price}=attrs) do
    members = if new_price < org_price, do: [:unit_price], else: []

    cast(product, attrs, members)
    |> validate_required(:id)
    |> validate_product()
  end

  def upload_imgage_changeset(product, attrs) do
    product
    |> cast(attrs, [:image_upload])
    |> validate_required([:image_upload])
  end

end
