defmodule DentoWeb.SurveyLive do
  use DentoWeb, :live_view
  alias Dento.{Catalog, Accounts, Survey}
  import DentoWeb.SurveyLive.Components

  alias DentoWeb.Endpoint
  @survey_results_topic "survey_results"

  @impl true
  def mount(_params, %{"user_token" => token} = _session, socket) do
    {
      :ok,
      socket
      |> assign_user(token)
      |> assign_demographic()
      |> assign_products()
    }
  end

  defp assign_products(%{assigns: %{current_user: user}} = socket) do
    socket
    |> assign(:products, Catalog.list_products_with_user_ratings(user))
  end

  defp assign_product(%{assigns: %{products: products}} = socket, product_index, new_product) do
    socket
    |> assign(:products, List.replace_at(products, product_index, new_product))
  end

  defp assign_demographic(%{assigns: %{current_user: current_user}} = socket) do
    socket
    |> assign(:demographic, Survey.get_demographic_by_user(current_user))
  end

  defp assign_user(socket, token) do
    socket
    |> assign_new(:current_user, fn -> Accounts.get_user_by_session_token(token) end)
  end

  @impl true
  def handle_info({:created_demographic, demographic}, socket) do
    {
      :noreply,
      socket
      |> handle_demographic_created(demographic)
    }
  end

  @impl true
  def handle_info({:created_rating, updated_product, product_index}, socket) do
    {
      :noreply,
      socket
      |> handle_rating_created(updated_product, product_index)
    }
  end

  defp handle_rating_created(
    %{assigns: %{products: products}} = socket,
    updated_product,
    product_index
  ) do

    Endpoint.broadcast(@survey_results_topic, "rating_created", %{})
    socket
    |> put_flash(:info, "Rating submitted successfully")
    |> assign_product(product_index, updated_product)
  end

  @impl true
  def handle_event("test", _params, socket) do
    {
      :noreply,
      socket
      |> put_flash(:error, "Howdy")
    }
  end

  defp handle_demographic_created(socket, demographic) do
    socket
    |> put_flash(:info, "Demographic created successfully")
    |> assign(:demographic, demographic)
  end

end
