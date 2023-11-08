defmodule DentoWeb.WrongLive do
  use DentoWeb, :live_view

  def mount(_params, session, socket) do

    state = start_state()
    |> Map.put(:user, Dento.Accounts.get_user_by_session_token(session["user_token"]))
    |> Map.put(:session_id, session["live_socket_id"])
    {
      :ok,
      assign(
        socket,
        state
      )
    }
  end

  def time() do
    DateTime.utc_now |> to_string
  end


  def render(assigns) do
   ~H"""
   <h1> The time is: <%= @time %></h1>
   <h1>Your score: <%= @score %></h1>
   <h2>
    <%= @message %>
    <%= if @game_over do%>
      <a href="#" class="bg-green-100" phx-click="play_again">Play again?</a>
    <% end %>
   </h2>
   <%!-- <%=@answer%> --%>
   <h2>
    <%= if not @game_over do%>
      <%= for n <- 1..10 do %>
        <a class="bg-blue-200" href="#" phx-click="guess" phx-value-number={n}><%= n %></a>
      <% end %>
    <% end %>
   </h2>

   <pre>
   Hello <%=@user.username %>
   </pre>
   """
  end

  def start_state() do
    %{
      score: 10,
      message: "Guess a number.",
      time: time(),
      answer: :rand.uniform(10),
      game_over: false
    }
  end

  def handle_event("play_again", _, socket) do
    {
      :noreply,
      assign(
        socket,
        start_state()
      )
    }
  end

  def handle_event("guess", %{"number" => guess}=data, socket) do
    result = String.to_integer(guess, 10) ==  socket.assigns.answer
    if result do
      message = "Your guess: #{guess}. Right."
      {
        :noreply,
        assign(
          socket,
          message: message,
          time: time(),
          game_over: result
        )
     }
    else
      score = socket.assigns.score - 1
      message = "Your guess: #{guess}. Wrong. \n Guess again."
      {
        :noreply,
        assign(
          socket,
          message: message,
          score: score,
          time: time()
        )
     }
    end
  end
end
