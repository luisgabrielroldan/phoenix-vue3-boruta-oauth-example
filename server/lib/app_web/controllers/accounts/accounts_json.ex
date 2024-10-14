defmodule AppWeb.Accounts.AccountsJSON do
  @moduledoc false

  alias App.Accounts.User

  def user_settings(%{user: %User{} = user}) do
    %{
      success: true,
      data: %{
        email: user.email
      }
    }
  end
end
