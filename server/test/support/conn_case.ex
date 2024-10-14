defmodule AppWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use AppWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint AppWeb.Endpoint

      use AppWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import AppWeb.ConnCase
      import OpenApiSpex.TestAssertions

      alias AppWeb.ApiSpec
    end
  end

  setup tags do
    App.DataCase.setup_sandbox(tags)

    conn =
      Phoenix.ConnTest.build_conn()
      |> Plug.Conn.put_req_header("content-type", "application/json")

    {:ok, conn: conn}
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_authorize

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_authorize(%{conn: conn}) do
    user = App.AccountsFixtures.user_fixture()
    %{conn: authorize_user(conn, user), user: user}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """

  def authorize_user(conn, user, scopes \\ []) do
    token =
      AppWeb.BorutaFactory.insert(:token,
        type: "access_token",
        scope: Enum.join(scopes, " "),
        sub: "#{user.id}"
      )

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_req_header("content-type", "application/json")
    |> Plug.Conn.put_req_header("authorization", "Bearer #{token.value}")
  end
end
