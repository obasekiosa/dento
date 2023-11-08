defmodule Dento.Survey.Demographic.Query do
  import Ecto.Query
  alias Dento.Survey.Demographic

  def base, do: Demographic

  def for_user(query \\ base(), user) do
    query
    |> where([d], d.user_id == ^user.id)
  end
end
