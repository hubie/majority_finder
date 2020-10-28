defmodule MajorityFinderWeb.Components.QuestionComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <h1 class="question">
      <%= get_in(@question, [:question]) %>
    </h1>
    <div class="voter answers">
      <%= for answer <- get_in(@question, [:answers]) || [] do %>
        <button phx-click="submitAnswer" class="voter answer" value="<%= answer %>"><%= answer %></button>
      <% end %>
    </div>
    <div id="countdownTimer" phx-hook="Timer"></div>
    """
  end
end