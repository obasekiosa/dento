defmodule DentoWeb.SurveyLive.RatingsLive.FormComponent do
  use DentoWeb, :live_component

  alias Dento.Survey
  alias Dento.Survey.Rating

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_rating()
      |> assign_form()
    }
  end

  defp assign_rating(%{assigns: %{user: user, product: product}} = socket) do
    socket
    |> assign(:rating, %Rating{user_id: user.id, product_id: product.id})
  end

  defp assign_form(%{assigns: %{rating: rating}} = socket) do
    socket
    |> assign(:form, to_form(Survey.change_rating(rating)))
  end

  defp assign_form(%{assigns: %{rating: rating}} = socket, changeset) do
    socket
    |> assign(:form, to_form(changeset))
  end

  @impl true
  def handle_event("save", %{"rating" => rating_params}, socket) do
    {
      :noreply,
      socket
      |> save_rating(rating_params)
      |> put_flash(:warning, "saved?")
    }
  end

  defp save_rating(%{assigns: %{product_index: product_index, product: product}
        } = socket, rating_params) do

    case Survey.create_rating(rating_params) do
      {:ok, rating} ->
        product = %{product | ratings: [rating]}
        send(self(), {:created_rating, product, product_index})
        socket
      {:error, %Ecto.Changeset{} = changeset} ->
        assign_form(socket, changeset)
    end
  end

  @impl true
  def handle_event("validate", %{"rating" => rating_params}, socket) do
    {
      :noreply,
      socket
      |> validate_rating(rating_params)
      |> put_flash(:info, "Validated?")
    }
  end

  defp validate_rating(%{assigns: %{rating: rating}} = socket, rating_params) do
    changeset =
      rating
      |> Survey.change_rating(rating_params)
      |> Map.put(:action, :validate)

      socket
      |> assign_form(changeset)
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="border border-[3px] p-1">
        <section>
          <h4 class="font-normal text-2xl"><%= @product.name %></h4>
        </section>
        <section>
          <.form class="flex items-center space-x-1 " for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
            <.label for{@form[:stars]}>Stars</.label>
            <.input field={@form[:stars]} type="select" options={Enum.reverse(1..5)} />
            <.input field={@form[:user_id]} type="hidden" />
            <.input field={@form[:product_id]} type="hidden" />
            <.button class="h-[30px] py-[2px]" phx-disable-with="Saving...">Save</.button>
          </.form>
        </section>
      </div>
    """
  end
end
