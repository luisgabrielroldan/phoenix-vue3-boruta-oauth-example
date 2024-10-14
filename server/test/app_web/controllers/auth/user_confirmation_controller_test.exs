defmodule AppWeb.Auth.UserConfirmationControllerTest do
  use AppWeb.ConnCase, async: true

  alias App.Accounts
  alias App.Repo
  import App.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "POST /api/users/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/api/users/confirm", %{
          "email" => user.email
        })

      assert %{"success" => true} = resp = json_response(conn, 200)
      assert_schema(resp, "SuccessResponse", ApiSpec.spec())

      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "confirm"
    end

    test "does not send confirmation token if User is confirmed", %{conn: conn, user: user} do
      Repo.update!(Accounts.User.confirm_changeset(user))

      conn =
        post(conn, ~p"/api/users/confirm", %{
          "email" => user.email
        })

      assert %{"success" => true} = resp = json_response(conn, 200)
      assert_schema(resp, "SuccessResponse", ApiSpec.spec())

      refute Repo.get_by(Accounts.UserToken, user_id: user.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/users/confirm", %{
          "email" => "unknown@example.com"
        })

      assert %{"success" => true} = resp = json_response(conn, 200)
      assert_schema(resp, "SuccessResponse", ApiSpec.spec())

      assert Repo.all(Accounts.UserToken) == []
    end
  end

  describe "POST /api/users/confirm/:token" do
    test "confirms the given token once", %{conn: conn, user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      conn = post(conn, ~p"/api/users/confirm/#{token}")
      assert %{"success" => true} = resp = json_response(conn, 200)
      assert_schema(resp, "SuccessResponse", ApiSpec.spec())

      assert Accounts.get_user!(user.id).confirmed_at
      assert Repo.all(Accounts.UserToken) == []

      conn =
        build_conn()
        |> authorize_user(user)
        |> post(~p"/api/users/confirm/#{token}")

      assert %{
               "success" => false,
               "message" => "User confirmation link is invalid or it has expired."
             } = resp = json_response(conn, 400)

      assert_schema(resp, "GenericErrorResponse", ApiSpec.spec())
    end

    test "does not confirm email with invalid token", %{conn: conn, user: user} do
      conn = post(conn, ~p"/api/users/confirm/oops")

      assert %{
               "success" => false,
               "message" => "User confirmation link is invalid or it has expired."
             } = resp = json_response(conn, 400)

      assert_schema(resp, "GenericErrorResponse", ApiSpec.spec())

      refute Accounts.get_user!(user.id).confirmed_at
    end
  end
end
