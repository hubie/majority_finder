defmodule MajorityFinder.Questions do
  use GenServer

  @initial_state %{
    questions: []
  }

  @metricsInjestion inspect(MajorityFinder.Metrics)

  def start_link(args) do
    GenServer.start_link(__MODULE__, nil, args)
  end

  def subscribe do
    # Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @metricsInjestion)
  end

  @impl true
  def init(_state) do
    subscribe()
    {:ok, %{@initial_state | questions: load_questions()}}
  end

  @impl true
  def handle_call(:get_questions, _from, state) do
    {:reply, state.questions, state}
  end

  @impl true
  def handle_call(%{get_question: id}, _from, state) do
    {:reply, Enum.find(state.questions, fn x -> x.id == id end), state}
  end

  defp load_questions() do
    "questions.json"
      |> File.read!
      |> Jason.decode!(keys: :atoms)
      |> Enum.with_index()
      |> Enum.map(fn {q, i} -> Map.put(q, :id, Map.get(q, :id, :crypto.hash(:md5, "#{i}") |> Base.encode16() )) end)
  end

end
