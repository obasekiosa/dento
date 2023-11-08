defmodule DentoWeb.ProductLive.FormComponent do
  use DentoWeb, :live_component

  alias Dento.Catalog
  alias DentoWeb.Endpoint

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage product records in your database.</:subtitle>
      </.header>



        <%= for entry <- @uploads.image.entries do %>
          <figure>
            <.live_img_preview entry={entry} />
            <figcaption><%= entry.client_name %></figcaption>
          </figure>
          <progress value={entry.progress} max="100"> <%= entry.progress %>% </progress>
        <% end %>


      <.simple_form
        for={@form}
        id="product-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:unit_price]} type="number" label="Unit price" step="any" />
        <.input field={@form[:sku]} type="number" label="Sku" />
        <.input field={@form[:image_upload]} type="hidden" />
        <section phx-drop-target={@uploads.image.ref}>
          <.live_file_input upload={@uploads.image} />
        </section>
        <:actions>
          <.button phx-disable-with="Saving...">Save Product</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{product: product} = assigns, socket) do
    changeset = Catalog.change_product(product)
    {:ok,
      socket
      |> assign(assigns)
      |> assign_form(changeset)
      |> allow_upload(:image,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 1,
        # auto_upload: true,
        progress: &handle_progress/3
      )
    }
  end

  defp handle_progress(:image, entry, socket) do
    :timer.sleep(1000)
    if entry.done? do
      uploaded_file =
        consume_uploaded_entry(socket, entry, &upload_static_file(&1, socket))

      {
        :noreply,
        socket
        |> put_flash(:info, "file #{entry.client_name} uploaded")
        |> update_changeset(:image_upload, uploaded_file)
      }
    else
      {:noreply, socket}
    end
  end

  def update_changeset(%{assigns: %{form: form}} = socket, key, value) do
    changeset = Ecto.Changeset.put_change(form.source, key, value)
    socket
    |> assign_form(changeset)
  end

  defp upload_static_file(%{path: path}=meta, socket) do
    # Plug in your production image file persistence implementation here!
    dest = Path.join("priv/static/images", Path.basename(path) <> ".png")
    # dest = Path.join([:code.priv_dir(:dento), "static", "uploads", Path.basename(path)])
    File.cp!(path, dest)
    route = Endpoint.static_path("/images/#{Path.basename(dest)}")
    {:ok, ~p"/images/#{Path.basename(dest)}"}
  end



  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    IO.inspect(socket)
    changeset =
      socket.assigns.product
      |> Catalog.change_product(product_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    save_product(socket, socket.assigns.action, product_params)
  end

  defp save_product(socket, :edit, product_params) do
    IO.inspect(socket)
    case Catalog.update_product(socket.assigns.product, product_params) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_product(socket, :new, product_params) do
    case Catalog.create_product(product_params) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
