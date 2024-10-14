defmodule AppWeb.Oauth.RevokeControllerTest do
  use AppWeb.ConnCase, async: true
  import Phoenix.ConnTest

  import Mox

  alias Boruta.Oauth.Error

  setup :verify_on_exit!

  setup do
    {:ok, conn: build_conn()}
  end

  describe "revoke/2" do
    test "returns an oauth error", %{conn: conn} do
      error = %Error{
        status: :bad_request,
        error: :unknown_error,
        error_description: "Error description"
      }

      Boruta.OauthMock
      |> expect(:revoke, fn conn, module ->
        module.revoke_error(conn, error)
      end)

      conn = post(conn, ~p"/oauth/revoke", %{})

      assert json_response(conn, 400) == %{
               "error" => "unknown_error",
               "error_description" => "Error description"
             }
    end

    test "respond 200", %{conn: conn} do
      Boruta.OauthMock
      |> expect(:revoke, fn conn, module ->
        module.revoke_success(conn)
      end)

      conn = post(conn, ~p"/oauth/revoke", %{})

      assert response(conn, 200)
    end
  end
end
