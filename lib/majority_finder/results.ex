defmodule MajorityFinder.Results do
  use GenServer

  @initial_state %{
    results: %{},
    question: %{},
    voter_count: nil
  }

  @resultsTopic "results"
  @questionsTopic "questions"
  @metricsTopic "metrics"

  def start_link(args) do
    GenServer.start_link(__MODULE__, nil, args)
  end

  @impl true
  def init(state) do
    {:ok, @initial_state}
  end

  @impl true
  def handle_cast(%{vote_cast: vote}, state) do
    {_, new_state} = get_and_update_in(state, [:results, vote], &{&1, (&1 || 0) + 1})
    broadcast_results(new_state.results)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast(:reset_results, state) do
    new_state = %{state | results: %{}, question: %{}}
    broadcast_voting_closed()
    broadcast_results(new_state.results)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast(
        %{new_question: %{question: question, answers: possible_answers} = new_question},
        state
      ) do
    clean_results = Map.new(possible_answers, fn a -> {a, 0} end)
    broadcast_question(new_question)
    broadcast_results(clean_results)
    {:noreply, %{state | results: clean_results, question: new_question}}
  end

  @impl true
  def handle_cast(%{new_voter_count: voter_count}, state) do
    new_state = %{state | voter_count: voter_count}
    broadcast_metrics(%{voter_count: voter_count})
    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_current_results, _from, state) do
    {:reply, state.results, state}
  end

  @impl true
  def handle_call(:get_current_question, _from, state) do
    {:reply, state.question, state}
  end

  @impl true
  def handle_call(:get_current_voter_count, _from, state) do
    {:reply, state.voter_count, state}
  end

  defp broadcast_results(results) do
    Phoenix.PubSub.broadcast(
      MajorityFinder.PubSub,
      @resultsTopic,
      {__MODULE__, %{results: results}}
    )
  end

  defp broadcast_question(question) do
    Phoenix.PubSub.broadcast(
      MajorityFinder.PubSub,
      @questionsTopic,
      {__MODULE__, %{new_question: question}}
    )
  end

  defp broadcast_voting_closed() do
    Phoenix.PubSub.broadcast(MajorityFinder.PubSub, @questionsTopic, {__MODULE__, :voting_closed})
  end

  defp broadcast_metrics(metrics) do
    Phoenix.PubSub.broadcast(
      MajorityFinder.PubSub,
      @metricsTopic,
      {__MODULE__, %{online_voters: metrics.voter_count}}
    )
  end

  def vote_cast(answer) do
    GenServer.cast(__MODULE__, %{vote_cast: answer})
  end

  def reset_results() do
    GenServer.cast(__MODULE__, :reset_results)
  end

  def get_current_results() do
    GenServer.call(__MODULE__, :get_current_results)
  end

  def get_current_question() do
    GenServer.call(__MODULE__, :get_current_question)
  end

  def get_current_voter_count() do
    GenServer.call(__MODULE__, :get_current_voter_count)
  end

  def new_question(question) do
    GenServer.cast(__MODULE__, %{new_question: question})
  end

  def update_user_count(new_count) do
    GenServer.cast(__MODULE__, %{new_voter_count: new_count})
  end
end
