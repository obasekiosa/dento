defmodule Dento.Promo do
  alias Dento.Promo.Recipient
  import Ecto.Changeset

  def change_recipient(%Recipient{} = recipient, attrs \\ %{}) do
    Recipient.changeset(recipient, attrs)
  end

  def send_promo(recipient_changeset, attrs \\ %{}) do
    with {:ok , recipient} <- apply_action(recipient_changeset, :send_promo)
    do
      %Recipient{first_name: first_name, email: email} = recipient
      IO.puts("Sending promo to #{first_name} at #{email} ...")
      :timer.sleep(2000)
      IO.puts("Successfully sent promo to #{first_name} at #{email}")
      {:ok , nil}
    else
      err -> err
    end
  end
end
