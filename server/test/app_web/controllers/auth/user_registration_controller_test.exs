defmodule AppWeb.Auth.UserRegistrationControllerTest do
  use AppWeb.ConnCase, async: true

  import App.AccountsFixtures

  describe "POST /api/users/register" do
    @tag :capture_log
    test "creates account and logs the user in", %{conn: conn} do
      email = unique_user_email()

      conn =
        post(conn, ~p"/api/users/register", %{
          "user" => valid_user_attributes(email: email)
        })

      assert %{"success" => true} = resp = json_response(conn, 200)
      assert_schema(resp, "SuccessResponse", ApiSpec.spec())
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, ~p"/api/users/register", %{
          "user" => %{"email" => "with spaces", "password" => "too short"}
        })

      resp = json_response(conn, 400)

      assert_schema(resp, "SchemaErrorResponse", ApiSpec.spec())

      assert %{
               "success" => false,
               "errors" => errors
             } = resp

      assert %{
               "detail" => "Should be at least 12 character(s).",
               "source" => %{"pointer" => "/password"},
               "title" => "Invalid value"
             } in errors

      assert %{
               "detail" => "Must have the @ sign and no spaces.",
               "source" => %{"pointer" => "/email"},
               "title" => "Invalid value"
             } in errors
    end
  end
end
