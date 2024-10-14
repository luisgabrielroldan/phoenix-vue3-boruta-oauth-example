defmodule AppWeb.Auth.UserResetPasswordController do
  use AppWeb, :api_controller

  alias App.Accounts
  alias App.Accounts.User
  alias AppWeb.Shared.Schemas.{GenericErrorResponse, SchemaErrorResponse, SuccessResponse}
  alias AppWeb.Auth.Schemas.{ConfirmPasswordResetRequest, ResetPasswordRequest}

  tags(["auth"])

  operation(:create,
    summary: "Reset user password",
    operation_id: "ResetPassword",
    request_body: ResetPasswordRequest.request(),
    responses: %{
      ok: SuccessResponse.response(),
      unprocessable_entity: SchemaErrorResponse.response()
    }
  )

  def create(%{body_params: %ResetPasswordRequest{user: %{email: email}}}, _params) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/api/users/reset_password/#{&1}")
      )
    end

    :ok
  end

  operation(:update,
    summary: "Confirm user password",
    operation_id: "ConfirmPasswordReset",
    request_body: ConfirmPasswordResetRequest.request(),
    parameters: [
      token: [
        in: :path,
        type: :string,
        required: true
      ]
    ],
    responses: %{
      ok: SuccessResponse.response(),
      not_found: GenericErrorResponse.response(),
      bad_request: SchemaErrorResponse.response(),
      unprocessable_entity: SchemaErrorResponse.response()
    }
  )

  def update(%{body_params: %ConfirmPasswordResetRequest{password: password}}, %{token: token}) do
    with {:user, %User{} = user} <- {:user, Accounts.get_user_by_reset_password_token(token)},
         {:ok, _} <- Accounts.reset_user_password(user, %{password: password}) do
      :ok
    else
      {:user, _} ->
        {:error, :not_found, "Reset password link is invalid or it has expired."}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, :bad_request, changeset}
    end
  end
end
