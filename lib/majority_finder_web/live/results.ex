defmodule MajorityFinderWeb.Results do
  use Phoenix.LiveView

  alias MajorityFinder.Results

  @topic inspect(__MODULE__)
  @resultsTopic "results"

  def subscribe do
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @topic)
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @resultsTopic)
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: subscribe()

    results = Results.get_current_results()
    new_socket = push_event(socket, "new_results", %{data: formatResults(results)})
    {:ok, assign(new_socket, :state, %{results: results})}
  end

  def handle_info({Results, %{results: results}}, socket) do
    new_socket = push_event(socket, "new_results", %{data: formatResults(results)})

    {:noreply, update(new_socket, :state, &Map.put(&1, :results, results))}
  end

  defp formatResults(results) do
    for {k, v} <- results, into: %{}, do: {k |> Atom.to_string() |> String.capitalize(), v}
  end

  def render(assigns) do
    ~L"""
    <div class="resultscontainer">
      <%= live_component(
        @socket,
        MajorityFinderWeb.Components.ResultsComponent
        )
      %>
    </div>
    """
  end
end
