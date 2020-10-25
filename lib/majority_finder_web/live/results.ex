defmodule MajorityFinderWeb.Results do
  use Phoenix.LiveView

  alias MajorityFinder.Results

  @topic inspect(__MODULE__)
  @resultsTopic "results"

  def subscribe do
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @topic)
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @resultsTopic)
  end

  def mount(params, _session, socket) do
    if connected?(socket), do: subscribe()

    case Results.get_current_results() do
      %{question: %{question: question}, results: results} ->
        new_socket = push_event(socket, "new_results", %{data: formatResults(results)})
        {:ok, assign(new_socket, :state, %{question: question, results: results, params: params})}
      %{question: %{}, results: %{}} ->
        new_socket = push_event(socket, "new_results", %{data: %{}})
        {:ok, assign(new_socket, :state, %{question: %{}, results: %{}, params: params})}
    end

  end

  def handle_info({Results, %{results: results} = stuff}, socket) do
    IO.inspect(["LOL", stuff])
    new_socket = push_event(socket, "new_results", %{data: formatResults(results)})

    {:noreply, update(new_socket, :state, &Map.put(&1, :results, results))}
  end

  defp formatResults(results) do
    results
  end

  def render(assigns) do
    case assigns.state.params do
      %{"view" => "headline"} ->
        Phoenix.View.render(MajorityFinderWeb.Results.HeadlineLive, "headline_live.html", assigns)
      _ ->
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
end
