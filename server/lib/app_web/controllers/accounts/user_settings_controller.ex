defmodule AppWeb.Accounts.UserSettingsController do
  use AppWeb, :api_controller

  alias App.Accounts
  alias AppWeb.Accounts.AccountsJSON
  alias AppWeb.Accounts.Schemas.{UserSettingsUpdateRequest, UserSettingsResponse}
  alias AppWeb.Shared.Schemas.{GenericErrorResponse, SchemaErrorResponse, SuccessResponse}

  tags(["accounts"])

  security([%{"authorization" => []}])

  operation(:show,
    summary: "Show user settings",
    operation_id: "ShowSettings",
    responses: %{
      ok: UserSettingsResponse.response("User settings")
    }
  )

  def show(conn, _params) do
    user = conn.assigns.current_user

    conn
    |> put_view(AccountsJSON)
    |> render(:user_settings, user: user)
  end

  operation(:update,
    summary: "Update user email or password",
    operation_id: "UpdateSettings",
    request_body: UserSettingsUpdateRequest.request(),
    responses: %{
      ok: SuccessResponse.response("Success"),
      bad_request: SchemaErrorResponse.response(),
      unprocessable_entity: SchemaErrorResponse.response()
    }
  )

  def update(conn, _params) do
    %UserSettingsUpdateRequest{action: action, current_password: password, user: user_params} =
      conn.body_params

    user = conn.assigns.current_user

    case action do
      "update_email" -> update_email(user, password, user_params)
      "update_password" -> update_password(user, password, user_params)
    end
  end

  defp update_email(user, password, user_params) do
    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        :ok

      {:error, changeset} ->
        {:error, :bad_request, changeset}
    end
  end

  defp update_password(user, password, user_params) do
    case Accounts.update_user_password(user, password, user_params) do
      {:ok, _user} ->
        :ok

      {:error, changeset} ->
        {:error, :bad_request, changeset}
    end
  end

  operation(:confirm_email,
    operation_id: "ConfirmEmail",
    summary: "Confirm user email",
    parameters: [
      token: [
        in: :path,
        type: :string,
        required: true
      ]
    ],
    responses: %{
      ok: SuccessResponse.response(),
      bad_request: GenericErrorResponse.response(),
      unprocessable_entity: SchemaErrorResponse.response()
    }
  )

  def confirm_email(conn, %{token: token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        :ok

      :error ->
        {:error, :not_found, "Email change link is invalid or it has expired."}
    end
  end
end
