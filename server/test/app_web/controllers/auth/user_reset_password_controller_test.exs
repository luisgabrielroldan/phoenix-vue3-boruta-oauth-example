defmodule AppWeb.Auth.UserResetPasswordControllerTest do
  use AppWeb.ConnCase, async: true

  alias App.Accounts
  alias App.Repo
  import App.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "POST /api/users/reset_password" do
    @tag :capture_log
    test "sends a new reset password token", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/api/users/reset_password", %{
          "user" => %{"email" => user.email}
        })

      assert %{"success" => true} = resp = json_response(conn, 200)

      assert_schema(resp, "SuccessResponse", ApiSpec.spec())

      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/users/reset_password", %{
          "user" => %{"email" => "unknown@example.com"}
        })

      assert %{"success" => true} = resp = json_response(conn, 200)

      assert_schema(resp, "SuccessResponse", ApiSpec.spec())

      assert Repo.all(Accounts.UserToken) == []
    end
  end

  describe "PUT /api/users/reset_password/:token" do
    setup %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{token: token}
    end

    test "resets password once", %{conn: conn, user: user, token: token} do
      conn =
        put(conn, ~p"/api/users/reset_password/#{token}", %{
          "password" => "new valid password"
        })

      assert %{"success" => true} = resp = json_response(conn, 200)

      assert_schema(resp, "SuccessResponse", ApiSpec.spec())

      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      conn =
        put(conn, ~p"/api/users/reset_password/#{token}", %{
          "password" => "too short"
        })

      assert resp = json_response(conn, 400)

      assert %{
               "success" => false,
               "errors" => errors
             } = resp

      assert %{
               "detail" => "Should be at least 12 character(s).",
               "source" => %{"pointer" => "/password"},
               "title" => "Invalid value"
             } in errors

      assert_schema(resp, "SchemaErrorResponse", ApiSpec.spec())
    end

    test "does not reset password with invalid token", %{conn: conn} do
      conn =
        put(conn, ~p"/api/users/reset_password/oops", %{
          "password" => "new valid password"
        })

      assert resp = json_response(conn, 404)

      assert %{
               "success" => false,
               "message" => "Reset password link is invalid or it has expired."
             } = resp

      assert_schema(resp, "GenericErrorResponse", ApiSpec.spec())
    end
  end
end
