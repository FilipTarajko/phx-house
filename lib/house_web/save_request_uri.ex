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

  defp save_request_path(_params, url, socket) do
    uri = URI.parse(url) |> Map.get(:path)
    uri_splits = String.split(uri, "/") |> Enum.drop(1)

    socket = socket
    |> Phoenix.Component.assign(:uri_splits, uri_splits)
    |> Phoenix.Component.assign(:current_uri, uri)

    {:cont, socket}
  end
end
