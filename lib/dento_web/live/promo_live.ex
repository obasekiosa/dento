defmodule DentoWeb.PromoLive do
  use DentoWeb, :live_view
  alias Dento.Promo
  alias Dento.Promo.Recipient

  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign_recipient()
      |> assign_changeset()
      |> assign_form()
      |> assign_promo_sent_status()
    }
  end

  defp assign_promo_sent_status(socket) do
    socket
    |> assign(:promo_sent_status, "unsent")
  end

  defp assign_recipient(socket) do
    socket
    |> assign(:recipient, %Recipient{})
  end

  defp assign_changeset(%{assigns: %{recipient: recipient }} = socket) do
    socket
    |> assign(:changeset, Promo.change_recipient(recipient))
  end

  defp assign_form(%{assigns: %{changeset: recipient_changeset }} = socket) do
    form = to_form(recipient_changeset)
    socket
    |> assign(:form, form)
  end

  def handle_event("validate", %{"recipient" => recipient_params}, %{assigns: %{recipient: recipient }} = socket) do

    changeset =
      recipient
      |> Promo.change_recipient(recipient_params)
      |> Map.put(:action, :validate)

      {
        :noreply,
        socket
        |> assign(:changeset, changeset)
        |> assign_form()
      }
  end

  def handle_event("save", %{"recipient" => recipient_params}, %{assigns: %{recipient: recipient }} = socket) do
    changeset =
      recipient
      |> Promo.change_recipient(recipient_params)
      |> Map.put(:action, :validate)

      if changeset.valid? do
        with {:ok , _} <- Promo.send_promo(changeset)
        do
          {
            :noreply,
            socket
            |> assign(:promo_sent_status, "success")
            |> assign_recipient()
            |> assign_changeset()
            |> assign_form()
          }
        else
          {:error, changeset} -> {
              :noreply,
              socket
              |> assign(:promo_sent_status, "failed")
              |> assign(:changeset, changeset)
              |> assign_form()
            }
        end
      else
        {
          :noreply,
          socket
          |> assign(:changeset, changeset)
          |> assign_form()
        }
      end
  end
end
