defmodule DentoWeb.SurveyLive.DemographicLive.FromComponent do
  use DentoWeb, :live_component

  import Phoenix.HTML.Form

  alias Dento.Survey
  alias Dento.Survey.Demographic

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
    }
  end

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_demographic()
      |> assign_form()
    }
  end

  defp assign_demographic(%{assigns: %{user: user}} = socket) do
    assign(socket, :demographic, %Demographic{user_id: user.id})
  end

  defp assign_changeset(%{assigns: %{demographic: demographic}} = socket) do
    assign(socket, :changeset, Survey.change_demographic(demographic))
  end


  defp assign_form(%{assigns: %{demographic: demographic}} = socket) do
    changeset = Survey.change_demographic(demographic)
    assign(socket, :form, to_form(changeset))
  end

  defp assign_form(socket, %Ecto.Changeset{}=changeset) do
    assign(socket, :form, to_form(changeset))
  end

  def handle_event("save", %{"demographic" => demographic_params}, socket) do
    :timer.sleep(1000)
    {
      :noreply,
      socket
      |> save_demographic(demographic_params)
    }
  end

  defp save_demographic(socket, demographic_params) do
    case Survey.replace_demographic(demographic_params) do
      {:ok, demographic} ->
        send(self(), {:created_demographic, demographic})
        socket
      {:error, %Ecto.Changeset{} = changeset} -> assign_form(socket, changeset)
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div>
        <div class="font-normal text-4xl"><%= @content %></div>
        <.form class="space-y-2" for={@form} id={"form-#{@id}"} phx-submit="save" phx-target={@myself}>
          <.input field={@form[:gender]} label="Gender" type="select" options={["female", "male", "other", "prefer not to say"]}/>
          <.input field={@form[:year_of_birth]} label="Year of birth" type="select" options={Enum.reverse(1940..2023)}/>
          <.input field={@form[:user_id]} type="hidden"/>
          <.button phx-disable-with="Saving...">Save</.button>
        </.form>
      </div>
    """
  end
end
