defmodule DentoWeb.AdminDashBoardLive.SurveyResultsLive do
  use DentoWeb, :live_component
  use DentoWeb, :chart_live

  alias Dento.Catalog


  defp assign_dataset(%{assigns: %{product_ratings_with_average_ratings: product_ratings }} = socket) do
    socket
    |> assign(:dataset, make_bar_chart_dataset(product_ratings))
  end


  defp assign_chart(%{assigns: %{dataset: dataset}} = socket) do
    socket
    |> assign(:chart, make_bar_chart(dataset))
  end

  defp assign_products_with_average_ratings(%{assigns: %{age_group_filter: age_group_filter}} = socket) do
    socket
    |> assign(
      :product_ratings_with_average_ratings,
      get_products_with_average_ratings(%{age_group_filter: age_group_filter})
    )
  end

  defp get_products_with_average_ratings(filter) do
    case Catalog.list_products_with_average_ratings(filter) do
      [] -> Catalog.list_products_with_zero_ratings()
      products -> products
    end
  end

  defp assign_chart_svg(%{assigns: %{chart: chart}} = socket) do
    socket
    |> assign(
      :chart_svg,
      render_bar_chart(chart, title(), subtitle(), x_axis(), y_axis())
    )
  end

  defp title, do: "Product Ratings"
  defp subtitle, do: "average star ratings per product"
  defp x_axis, do: "products"
  defp y_axis, do: "stars"

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_age_group_filter()
      |> assign_update_chart()
    }
  end


  defp assign_update_chart(socket) do
    socket
    |> assign_products_with_average_ratings()
    |> assign_dataset()
    |> assign_chart()
    |> assign_chart_svg()
  end

  defp assign_age_group_filter(
    %{assigns: %{age_group_filter: age_group_filter}} = socket
  ) do
      assign(socket, :age_group_filter, age_group_filter)
  end

  defp assign_age_group_filter(socket, filter \\ "all") do
    socket
    |> assign(:age_group_filter, filter)
  end

  @impl true
  def handle_event("filter-by-age-group", %{"age_filter" => filter}, socket) do
    {
      :noreply,
      socket
      |> assign_age_group_filter(filter)
      |> assign_update_chart()
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
      <section class="flex flex-col items-center">
        <.form class="max-w-[150px] self-center" phx-change="filter-by-age-group" phx-target={@myself}>
          <.input name="age_filter" options={["all", "18 and under", "18 to 25", "25 to 35", "35 and up"]} value={@age_group_filter} type="select" label="Filter by age group:" />
        </.form>
        <h1 class="text-3xl underline mt-12">Survey Results</h1>
        <%= @chart_svg %>
      </section>
    """
  end
end
