defmodule MajorityFinderWeb.Components.QuestionComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <h1 class="question">
      <%= get_in(@question, [:question]) %>
    </h1>
    <%= for answers <- get_in(@question, [:answers]) || [] do %>
      <button phx-click="submitAnswer" class="voter answers" value="<%= answers %>"><%= answers %></button>
    <% end %>
    <div id="countdownTimer" phx-hook="Timer"></div>
    """
  end
end