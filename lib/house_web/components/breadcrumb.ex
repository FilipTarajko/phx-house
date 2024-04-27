defmodule HouseWeb.Breadcrumb do
  use Phoenix.Component
  import HouseWeb.CoreComponents

  attr :links_data, :list, required: true

  def breadcrumbs(assigns) do
    ~H"""
    <div class="mt-4">
      <.link navigate={"/"}>
        PhxHouse
      </.link>
      <%= for link_data <- @links_data do %>
        <.icon name="hero-chevron-right" class="h-3 w-3" />
        <.link navigate={"/"<>link_data.path}>
          <%= link_data.segment %>
        </.link>
      <% end %>
    </div>
    """
  end
end
