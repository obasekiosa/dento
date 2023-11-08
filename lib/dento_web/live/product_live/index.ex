defmodule DentoWeb.ProductLive.Index do
  use DentoWeb, :live_view

  alias Dento.Catalog
  alias Dento.Catalog.Product


  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> stream(:products, Catalog.list_products())
      |> assign(%{greeting: "Welcome to Dento!"})
    }
  end

  defp stringer(%Dento.Catalog.Product{}=p) do
    ~s"""
    id: #{p.id}<br/>
    sku: #{p.sku}<br/>
    desc: #{p.description}<br/>
    price: #{p.unit_price}<br/>
    name: #{p.name}<br/><br/>
    """
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product")
    |> assign(:product, Catalog.get_product!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, %Product{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Products")
    |> assign(:product, nil)
  end

  @impl true
  def handle_info({DentoWeb.ProductLive.FormComponent, {:saved, product}}, socket) do
    {:noreply, stream_insert(socket, :products, product)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Catalog.get_product!(id)
    {:ok, _} = Catalog.delete_product(product)

    {:noreply, stream_delete(socket, :products, product)}
  end
end
