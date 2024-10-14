defmodule AppWeb.Accounts.UserSettingsControllerTest do
  use AppWeb.ConnCase, async: true

  alias App.Accounts
  alias AppWeb.ApiSpec
  import App.AccountsFixtures
  import OpenApiSpex.TestAssertions

  setup :register_and_authorize

  describe "GET /api/users/settings" do
    test "returns the user settings", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/users/settings")
      email = user.email

      assert %{"data" => %{"email" => ^email}} = resp = json_response(conn, 200)
      assert_schema(resp, "UserSettingsResponse", ApiSpec.spec())
    end
  end

  describe "PUT /api/users/settings (change password form)" do
    test "updates the user password", %{conn: conn, user: user} do
      conn =
        put(conn, ~p"/api/users/settings", %{
          "action" => "update_password",
          "current_password" => valid_user_password(),
          "user" => %{
            "password" => "new valid password"
          }
        })

      assert %{"success" => true} = resp = json_response(conn, 200)
      assert_schema(resp, "SuccessResponse", ApiSpec.spec())

      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "does not update password on invalid data", %{conn: conn} do
      conn =
        put(conn, ~p"/api/users/settings", %{
          "action" => "update_password",
          "current_password" => "invalid",
          "user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      assert %{"success" => false} = resp = json_response(conn, 400)

      assert %{"success" => false, "errors" => errors} = resp

      assert %{
               "detail" => "Should be at least 12 character(s).",
               "source" => %{"pointer" => "/password"},
               "title" => "Invalid value"
             } in errors

      assert %{
               "detail" => "Is not valid.",
               "source" => %{"pointer" => "/current_password"},
               "title" => "Invalid value"
             } in errors

      assert_schema(resp, "SuccessResponse", ApiSpec.spec())

      assert get_session(conn, :user_token) == get_session(conn, :user_token)
    end
  end

  describe "PUT /api/users/settings (change email form)" do
    @tag :capture_log
    test "updates the user email", %{conn: conn, user: user} do
      conn =
        put(conn, ~p"/api/users/settings", %{
          "action" => "update_email",
          "current_password" => valid_user_password(),
          "user" => %{"email" => unique_user_email()}
        })

      assert %{"success" => true} = resp = json_response(conn, 200)
      assert_schema(resp, "SuccessResponse", ApiSpec.spec())

      assert Accounts.get_user_by_email(user.email)
    end

    test "does not update email on invalid data", %{conn: conn} do
      conn =
        put(conn, ~p"/api/users/settings", %{
          "action" => "update_email",
          "current_password" => "invalid",
          "user" => %{"email" => "with spaces"}
        })

      assert %{"success" => false} = resp = json_response(conn, 400)

      assert %{"success" => false, "errors" => errors} = resp

      assert %{
               "detail" => "Must have the @ sign and no spaces.",
               "source" => %{"pointer" => "/email"},
               "title" => "Invalid value"
             } in errors

      assert %{
               "detail" => "Is not valid.",
               "source" => %{"pointer" => "/current_password"},
               "title" => "Invalid value"
             } in errors

      assert_schema(resp, "SuccessResponse", ApiSpec.spec())
    end
  end

  describe "POST /api/users/settings/confirm_email/:token" do
    setup %{user: user} do
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{token: token, email: email}
    end

    test "updates the user email once", %{conn: conn, user: user, token: token, email: email} do
      conn = post(conn, ~p"/api/users/settings/confirm_email/#{token}")

      assert %{"success" => true} = resp = json_response(conn, 200)
      assert_schema(resp, "SuccessResponse", ApiSpec.spec())

      refute Accounts.get_user_by_email(user.email)
      assert Accounts.get_user_by_email(email)

      conn = post(conn, ~p"/api/users/settings/confirm_email/#{token}")

      assert %{
               "success" => false,
               "message" => "Email change link is invalid or it has expired."
             } = resp = json_response(conn, 404)

      assert_schema(resp, "SuccessResponse", ApiSpec.spec())
    end

    test "does not update email with invalid token", %{conn: conn, user: user} do
      conn = post(conn, ~p"/api/users/settings/confirm_email/oops")

      assert %{
               "success" => false,
               "message" => "Email change link is invalid or it has expired."
             } = resp = json_response(conn, 404)

      assert_schema(resp, "SuccessResponse", ApiSpec.spec())

      assert Accounts.get_user_by_email(user.email)
    end

    test "fails if user is not authorized", %{token: token} do
      conn = build_conn()
      conn = post(conn, ~p"/api/users/settings/confirm_email/#{token}")
      assert json_response(conn, 401)
    end
  end
end
