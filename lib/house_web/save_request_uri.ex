defmodule HouseWeb.SaveRequestUri do
  def on_mount(:save_request_uri, _params, _session, socket),
    do:
      {:cont,
       Phoenix.LiveView.attach_hook(
         socket,
         :save_request_path,
         :handle_params,
         &save_request_path/3
       )}

  defp build_links_data_list(segments) do
    Enum.reduce(segments, [], fn segment, acc ->
      last_elem = Enum.at(acc, 0)
      path = if last_elem do
        last_elem.path <> "/" <> segment
      else
        segment
      end
      [%{path: path, segment: segment} | acc]
    end)
    |> Enum.reverse()
  end

  defp save_request_path(_params, url, socket) do
    uri = URI.parse(url) |> Map.get(:path)
    uri_splits = String.split(uri, "/") |> Enum.drop(1)
    links_data = build_links_data_list(uri_splits)

    socket = socket
    |> Phoenix.Component.assign(:links_data, links_data)

    {:cont, socket}
  end
end
