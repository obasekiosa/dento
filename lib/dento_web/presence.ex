defmodule DentoWeb.Presence do
  use Phoenix.Presence, otp_app: :dento, pubsub_server: Dento.PubSub

  alias DentoWeb.Presence
  alias Dento.Accounts

  @user_activity_topic "user_activity"


  def track_user(pid, product, token) do
    user = Accounts.get_user_by_session_token(token)
    Presence.track(
          pid,
          @user_activity_topic,
          product.name,
          %{users: [%{email: user.email}]}
        )

    # tracking_data = Presence.get_by_key(@user_activity_topic, product.name)
    # # |> IO.inspect()
    # case tracking_data do
    #   [] ->
    #     Presence.track(
    #       pid,
    #       @user_activity_topic,
    #       product.name,
    #       %{users: [%{email: user.email}]}
    #     )
    #   %{metas: info} -> #IO.inspect(info)
    #     case info do
    #       %{users: active_users_for_product} ->
    #         update_users(pid, @user_activity_topic, product.name, active_users_for_product, user)
    #         IO.inspect("match")
    #       info ->
    #         # IO.inspect(info)
    #         active_users_for_product = get_in(info, [Access.all(), :users])
    #         |> List.first()
    #         update_users(pid, @user_activity_topic, product.name, active_users_for_product, user)
    #         IO.inspect("no match")
    #     end
    # end
  end

  defp update_users(pid, topic, key, user_list, user) do
    # IO.inspect(user)
    exists = Enum.find(user_list, fn u -> u[:email] == user.email end)
    IO.inspect(user.email)
    if exists do
      users = user_list  ++ [%{email: user.email}]
      Presence.update(pid, topic, key, %{
        users: users
      })
    else
      Presence.track(
        pid,
        topic,
        key,
        %{users: [%{email: user.email}]}
      )
    end
  end

end
