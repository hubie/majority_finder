defmodule MajorityFinder.Results do
  use GenServer


  @initial_state %{
    results: %{},
    ballots: %{},
    question: %{},
    voter_count: nil,
    show_mode: :show
  }

  @max_votes 1

  @resultsTopic "results"
  @questionsTopic "questions"
  @metricsTopic "metrics"
  @showTopic "showControl"

  def start_link(args) do
    GenServer.start_link(__MODULE__, nil, args)
  end

  @impl true
  def init(_state) do
    {:ok, @initial_state}
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
        %{new_question: %{question: _question, answers: possible_answers} = new_question},
        state
      ) do
    clean_results = Map.new(possible_answers, fn a -> {a, 0} end)
    broadcast_question(new_question)
    broadcast_results(clean_results)
    {:noreply, %{state | results: clean_results, question: new_question, ballots: %{}}}
  end

  @impl true
  def handle_cast(%{new_voter_count: voter_count}, state) do
    new_state = %{state | voter_count: voter_count}
    broadcast_metrics(%{voter_count: voter_count})
    {:noreply, new_state}
  end

  @impl true
  def handle_cast(%{set_show_mode: mode}, state) do
    new_state = %{state | show_mode: mode}
    broadcast_show_mode(%{show_mode: mode})
    {:noreply, new_state}
  end

  @impl true
  def handle_call(%{voter_id: voter_id, vote_cast: _} = ballot, _from, state) do
    votes_for_voter = get_vote_count_for_voter(voter_id, state)
    cond do
      votes_for_voter < @max_votes ->
        new_state = tally_vote(ballot, state)
        broadcast_results(new_state.results)
        if votes_for_voter + 1 < @max_votes do
          {:reply, %{voter_state: :new_question}, new_state}
        else
          {:reply, %{voter_state: :voted}, new_state}
        end
      true -> {:reply, %{voter_state: :voted}, state}
    end
  end

  @impl true
  def handle_call(%{get_voter_state: voter_id}, _from, state) do
    vote_count = get_vote_count_for_voter(voter_id, state)
    voter_state = cond do
      %{} == state.question -> :voting_closed
      vote_count >= @max_votes -> :voted
      true -> :new_question
    end
    {:reply, voter_state, state}
  end

  @impl true
  def handle_call(:get_current_results, _from, state) do
    {:reply, state.results, state}
  end

  @impl true
  def handle_call(:get_current_show_mode, _from, state) do
    {:reply, state.show_mode, state}
  end

  @impl true
  def handle_call(:get_current_question, _from, state) do
    {:reply, state.question, state}
  end

  @impl true
  def handle_call(:get_current_voter_count, _from, state) do
    {:reply, state.voter_count, state}
  end

  defp get_vote_count_for_voter(voter_id, state) do
    (get_in(state, [:ballots, voter_id]) || []) |> Enum.count
  end

  defp tally_vote(%{voter_id: voter_id, vote_cast: vote}, state) do
    {_, new_state} = get_and_update_in(state, [:results, vote], &{&1, (&1 || 0) + 1})
    {_, new_state} = get_and_update_in(new_state, [:ballots, voter_id], &{&1, (&1 || []) ++ [vote]})
    new_state
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
      {__MODULE__, %{new_question: question, voter_state: :new_question}}
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

  defp broadcast_show_mode(mode) do
    Phoenix.PubSub.broadcast(MajorityFinder.PubSub, @showTopic, {__MODULE__, mode})
  end

  def vote_cast(voter_id, answer) do
    GenServer.call(__MODULE__, %{voter_id: voter_id, vote_cast: answer})
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

  def get_voter_state(voter_id) do
    GenServer.call(__MODULE__, %{get_voter_state: voter_id})
  end

  def set_show_mode(%{show_mode: mode}) do
    GenServer.cast(__MODULE__, %{set_show_mode: mode})
  end

  def get_current_show_mode() do
    GenServer.call(__MODULE__, :get_current_show_mode)
  end
end
