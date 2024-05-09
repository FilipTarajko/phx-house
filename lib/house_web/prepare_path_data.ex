defmodule HouseWeb.PreparePathData do
  def on_mount(:prepare_path_data, _params, _session, socket) do
    {:cont,
      Phoenix.LiveView.attach_hook(
        socket,
        :prepare_path_data,
        :handle_params,
        &prepare_path_data/3
      )
    }
  end

  defp prepare_path_data(params, url, socket) do
    uri = URI.parse(url) |> Map.get(:path)
    uri_with_substitutions = uri

    {uri_with_substitutions, socket} = prepare_warehouse_data(uri_with_substitutions, socket, params)
    {uri_with_substitutions, socket} = prepare_product_data(uri_with_substitutions, socket, params)

    if (socket.assigns && socket.assigns.current_user && Map.has_key?(socket.assigns, :current_user)) do
      IO.puts("Setting locale to #{socket.assigns.current_user.locale}")
      Gettext.put_locale(socket.assigns.current_user.locale)
    end

    uri_splits = String.split(uri, "/") |> Enum.drop(1)
    uri_with_substitutions_splits = String.split(uri_with_substitutions, "/") |> Enum.drop(1)
    links_data = build_links_data_list(uri_splits, uri_with_substitutions_splits)

    socket = socket
    |> Phoenix.Component.assign(:links_data, links_data)

    {:cont, socket}
  end

  defp build_links_data_list(segments, segments_with_substitutions) do
    Enum.reduce(Enum.zip(segments, segments_with_substitutions), [], fn segment_and_substitution, acc ->
      last_elem = Enum.at(acc, 0)
      path = if last_elem do
        last_elem.path <> "/" <> elem(segment_and_substitution, 0)
      else
        elem(segment_and_substitution ,0)
      end
      [%{path: path, segment_name: elem(segment_and_substitution, 1)} | acc]
    end)
    |> Enum.reverse()
  end

  defp prepare_warehouse_data(uri_with_substitutions, socket, params) do
    if (Map.has_key?(params, "warehouse_id")) do
      warehouse = House.Warehouses.get_warehouse!(params["warehouse_id"]) |> House.Repo.preload(:owner)
      {String.replace(uri_with_substitutions, params["warehouse_id"], warehouse.name, global: false),
        socket
        |> Phoenix.Component.assign(:warehouse, warehouse)
      }
    else
      {uri_with_substitutions, socket}
    end
  end

  defp prepare_product_data(uri_with_substitutions, socket, params) do
    if (Map.has_key?(params, "product_id")) do
      product = House.Warehouses.get_product!(params["product_id"])
      {String.replace(uri_with_substitutions, params["product_id"], product.name, global: false),
        socket
        |> Phoenix.Component.assign(:product, product)
      }
    else
      {uri_with_substitutions, socket}
    end
  end
end
