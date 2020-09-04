defmodule MajorityFinderWeb.Components.TitleComponent do
  use Phoenix.LiveComponent

  alias MajorityFinderWeb.Endpoint

  def render(assigns) do
    ~L"""
      <header>
        <section class="container">
          <nav role="navigation">
          </nav>
          <a href="https://www.theatreb.org/" class="b-logo">
            <img src="<%= Endpoint.static_path("/images/b_logo_white.png") %>" alt="Theatre B Logo"/>
          </a>
        </section>
      </header>
    """
  end
end