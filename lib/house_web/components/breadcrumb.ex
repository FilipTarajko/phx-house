defmodule HouseWeb.Breadcrumb do
  use Phoenix.Component
  import HouseWeb.CoreComponents

  attr :uri_splits, :list, required: true

  def breadcrumbs(assigns) do
    ~H"""
    <div class="mt-4">
      PhxHouse
      <%= for uri_split <- @uri_splits do %>
        <.icon name="hero-chevron-right" class="h-3 w-3" />
        <%= uri_split %>
      <% end %>
    </div>
    """
  end
end
