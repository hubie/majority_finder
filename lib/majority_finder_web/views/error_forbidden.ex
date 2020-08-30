# lib/my_app_web/views/error_view.ex
defmodule MajorityFinderWeb.ErrorForbidden do
  use MajorityFinderWeb, :view

  def render("403.html", _assigns) do
    "Forbidden"
  end
end
