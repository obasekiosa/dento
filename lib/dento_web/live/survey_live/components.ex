defmodule DentoWeb.SurveyLive.Components do
  use Phoenix.Component
  import Phoenix.HTML

  alias Phoenix.LiveView.JS
  import DentoWeb.Gettext

  def show_demographic(assigns) do
    ~H"""
      <div >
        <h2 class="font-normal text-4xl text-green-700 underline">Demographics</h2>
        <ul>
          <li>Gender: <%= @demographic.gender %></li>
          <li>Year of birth: <%= @demographic.year_of_birth %></li>
        </ul>
      </div>
    """
  end

  def index_rating(assigns) do
    ~H"""
      <h4>
        <%= @product.name%>
        <%= raw render_rating_stars(@rating.stars) %>
      </h4>
    """
  end

  def render_rating_stars(stars) do
    filled_stars(stars)
    |> Enum.concat(unfilled_stars(5 - stars))
    |> Enum.join(" ")
  end

  def filled_stars(stars) do
    List.duplicate("<span> * </span>", stars)
  end

  def unfilled_stars(stars) do
    List.duplicate("<span> _ </span>", stars)
  end

  def show_ratings(assigns) do
    ~H"""
    <div>
       <h2 :if={ratings_complete?(@products)} class="font-normal text-4xl text-green-700 underline">
        Ratings
        </h2>
        <div class="mt-2" :for={{product, index} <- Enum.with_index(@products)}>
          <%= if rating = List.first(product.ratings) do %>
              <.index_rating rating={rating} product={product} />
          <% else %>
              <.live_component module={ DentoWeb.SurveyLive.RatingsLive.FormComponent }
                  id={"ratings-#{@current_user.id}-#{product.id}"}
                  user={@current_user}
                  product={product}
                  product_index={index}
              />
          <% end %>
        </div>
      </div>
    """
  end

  defp ratings_complete?(products) do
    Enum.all?(products, &(length(&1.ratings) == 1))
  end
end
