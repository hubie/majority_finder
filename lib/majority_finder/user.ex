defmodule MajorityFinder.User do
  @behaviour Bodyguard.Policy

  defstruct validation_code: nil, id: nil, role: nil

  @voter_codes []
  @admin_codes [System.get_env("ADMIN_LOGIN_CODE")]
  @refresh_period 120

  def get_user(%{user_id: user_id}) do
    get_user(%{validation_code: user_id})
  end

  def get_user(user) do
    IO.inspect(user, label: "USER")
    current_time = DateTime.utc_now |> DateTime.to_unix
    case :ets.lookup(:auth_meta, :last_refresh) do
      [] ->
        IO.inspect("BRAND NEW")
        get_user(user, :stale)
      [{_, last_refresh}] when last_refresh + @refresh_period < current_time ->
        IO.inspect(last_refresh, label: "LAST_REFRESH_STALE")
        get_user(user, :stale)
      meh ->
        IO.inspect(meh, label: "LAST_REFRESH_FRESH")
        get_user(user, :fresh)
    end
  end

  def get_user(%{validation_code: validation_code} = user, list_state) do
    case :ets.lookup(:auth_codes, :"#{validation_code}") do
      [{_, :admin}] ->
        %__MODULE__{validation_code: validation_code, id: validation_code, role: :admin}
      [{_, :voter}] ->
        %__MODULE__{validation_code: validation_code, id: validation_code, role: :voter}
      meh ->
        case list_state do
          :stale ->
            IO.inspect(meh, label: "Refreshing codes, existing codes:")

            refresh_voter_codes()
            get_user(user, :fresh)
          _ ->
            IO.inspect(meh, label: "Code not found in list:")

            false
        end
    end
  end

  defp refresh_voter_codes() do
    # :ets.delete_all_objects(:auth_codes)

    vc = @voter_codes |> Enum.map(fn vc -> {:"#{vc}", :voter} end)
    :ets.insert(:auth_codes, vc)
    ac = @admin_codes |> Enum.map(fn ac -> {:"#{ac}", :admin} end)
    :ets.insert(:auth_codes, ac)

    {:ok, pid} = GSS.Spreadsheet.Supervisor.spreadsheet(System.get_env("VOTER_CODE_SHEET_ID"))
    
    get_codes(pid)
    Process.exit(pid, :kill)

    refresh_time = DateTime.utc_now |> DateTime.to_unix
    :ets.insert(:auth_meta, {:last_refresh,  refresh_time})
  end

  defp get_codes(pid) do
    get_codes(pid, 1)
  end

  defp get_codes(pid, start_row) do
    max_rows = 300
    end_row = start_row+max_rows

    {:ok, fetched_codes} = GSS.Spreadsheet.read_rows(pid, start_row, end_row, column_to: 1)
    new_codes = fetched_codes |> List.flatten |> Enum.filter(& !is_nil(&1))

    case Enum.count(new_codes) do
      0 ->
        :ok
      _ ->
        vc = new_codes |> Enum.map(fn vc -> {:"#{vc}", :voter} end)
        :ets.insert(:auth_codes, vc)
        get_codes(pid, end_row+1)
    end
  end

  def authorize(_, %__MODULE__{role: :admin}, _), do: true
  def authorize(:voter, %__MODULE__{role: :voter}, _), do: true
  def authorize(action, %{user_id: user_id}, params), do: authorize(action, get_user(%{user_id: user_id}), params)
  def authorize(_action, _user, _params), do: false
end
