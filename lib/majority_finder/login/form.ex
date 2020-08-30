defmodule MajorityFinder.Login.Form do
  alias MajorityFinder.User
  @valid_codes ["0000"]

  def get_user_by_code(user) do
    user
    |> verify_user
  end

  def verify_user(%{validation_code: validation_code} = user) do
    case validation_code in @valid_codes do
      true -> %User{validation_code: validation_code, id: "some_id"}
      _ -> false
    end
  end
end
