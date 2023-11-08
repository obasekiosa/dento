defmodule DentoWeb.AdminDashBoardLive.UserActivityLive do
  use DentoWeb, :live_component

  alias DentoWeb.Presence

  @user_activity_topic "user_activity"

  @impl true
  def update(_assigns, socket) do
    {
      :ok,
      socket
      |> assign_user_activity()
    }
  end

  defp assign_user_activity(socket) do
    presence_map = Presence.list(@user_activity_topic)
    user_activity =
      presence_map
      |> Enum.map(fn {product_name, data} ->
        users = get_in(data, [:metas, Access.all(), :users])
        |> Enum.map(&List.first/1)

        {product_name, users}
      end)

      assign(socket, :user_activity, user_activity)
  end


  @impl true
  def render(assigns) do
    ~H"""
      <div class="border border-2 border-slate-6 py-400 px-2 py-4">
        <h2 class="bg-purple-900 text-white p-2 text-2xl font-light">User Activity</h2>
        <p class="px-6 py-4">Active users currently viewing games</p>
        <div :for={{product_name, users} <- @user_activity}>
          <h3 class="bg-purple-900 text-white p-2 mb-2 text-xl font-light"><%= product_name %></h3>
          <ul class="px-6 pb-2 space-y-2" :for={user <- users}>
            <li class=""><span class="mr-2">•</span> <%= user.email %></li>
           </ul>
        </div>
      </div>
    """
  end
end
