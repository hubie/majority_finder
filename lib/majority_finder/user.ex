defmodule MajorityFinder.User do
  @behaviour Bodyguard.Policy

  defstruct validation_code: nil, id: nil, role: nil

  @voter_codes ["0000"]
  @admin_codes ["9999"]

  def get_user(%{user_id: user_id}) do
    get_user(%{validation_code: user_id})
  end

  def get_user(%{validation_code: validation_code} = _user) do
    case validation_code do
      vc when vc in @admin_codes ->
        %__MODULE__{validation_code: validation_code, id: validation_code, role: :admin}

      vc when vc in @voter_codes ->
        %__MODULE__{validation_code: validation_code, id: validation_code, role: :voter}

      _ ->
        false
    end
  end

  def authorize(_, %__MODULE__{role: :admin}, _), do: true
  def authorize(:voter, %__MODULE__{role: :voter}, _), do: true
  def authorize(action, %{user_id: user_id}, params), do: authorize(action, get_user(%{user_id: user_id}), params)
  def authorize(_action, _user, _params), do: false
end
