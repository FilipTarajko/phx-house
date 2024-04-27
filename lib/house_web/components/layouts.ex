defmodule HouseWeb.Layouts do
  use HouseWeb, :html
  import HouseWeb.Breadcrumb

  embed_templates "layouts/*"
end
