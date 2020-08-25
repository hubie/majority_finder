defmodule MajorityFinderWeb.Results do
  use Phoenix.LiveView

  alias MajorityFinderWeb.Voter

  @topic "results"

  def handle_info({Voter, %{vote: vote}}, state) do
    current_value = Map.get(state.assigns.state.results, vote)
    new_state = update(state, :state, &(put_in(&1,[:results, vote], current_value + 1)))
    {:noreply, new_state}
  end


  def mount(_params, _session, socket) do
    if connected?(socket), do: MajorityFinderWeb.Voter.subscribe()
    {:ok, assign(socket, :state, %{results: %{yes: 0, no: 0}})}
  end


  def render(assigns) do
    ~L"""
    <div>
      <h1>Yes' are: <%= @state.results.yes %></h1>
      <h1>Noes are: <%= @state.results.no %></h1>
    </div>
    """
  end
end
