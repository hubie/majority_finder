defmodule MajorityFinder.Metrics do
  use GenServer

  alias MajorityFinder.Results

  @initial_state %{
    online_voter_count: 0,
    question: %{}
  }

  @metricsInjestion inspect(MajorityFinder.Metrics)

  def start_link(args) do
    GenServer.start_link(__MODULE__, nil, args)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @metricsInjestion)
  end

  @impl true
  def init(_state) do
    subscribe()
    {:ok, @initial_state}
  end

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{online_voter_count: count} = socket
      ) do
    user_count = count + map_size(joins) - map_size(leaves)

    Results.update_user_count(user_count)
    {:noreply, %{socket | online_voter_count: user_count}}
  end
end
