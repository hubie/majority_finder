defmodule MajorityFinderWeb.Components.TitleComponent do
  use Phoenix.LiveComponent

  alias MajorityFinderWeb.Endpoint

  def render(assigns) do
    ~L"""
      <header>
        <section class="container">
          <nav role="navigation">
            <a href="https://www.theatreb.org">Theatre B</a>
            Digital Playbill
          </nav>
          <a href="https://www.theatreb.org/" class="b-logo">
            <img src="<%= Endpoint.static_path("/images/b_logo_white.png") %>" alt="Theatre B Logo"/>
          </a>
          <h1>The Majority</h1>
        </section>
      </header>
    """
  end
end