defmodule MajorityFinder.Login.Form do
  alias MajorityFinder.User
  @voter_codes ["0000"]
  @admin_codes ["9999"]

  def get_user_by_code(user) do
    user
    |> verify_user
  end

  def verify_user(%{validation_code: validation_code} = user) do
    case validation_code do
      vc when vc in @admin_codes ->
        IO.inspect("ITS AN ADMIN")
        %User{validation_code: validation_code, id: "some_id", role: :admin}

      vc when vc in @voter_codes ->
        %User{validation_code: validation_code, id: "some_id", role: :voter}

      _ ->
        false
    end
  end
end
