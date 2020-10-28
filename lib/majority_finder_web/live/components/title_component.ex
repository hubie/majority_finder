defmodule MajorityFinderWeb.Components.TitleComponent do
  use Phoenix.LiveComponent

  alias MajorityFinderWeb.Endpoint

  def render(assigns) do
    ~L"""
      <header>
        <section class="container">
          <div>
          </div>
          <a href="https://www.theatreb.org/" class="b-logo">
            <img src="<%= Endpoint.static_path("/images/bee_logo.png") %>" alt="Theatre B Logo"/>
          </a>
          <h1>The Majority</h1>
        </section>
      </header>
    """
  end
end