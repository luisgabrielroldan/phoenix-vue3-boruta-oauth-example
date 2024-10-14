defmodule AppWeb.Auth.UserConfirmationController do
  use AppWeb, :api_controller

  alias App.Accounts
  alias AppWeb.Shared.Schemas.{GenericErrorResponse, SchemaErrorResponse, SuccessResponse}
  alias AppWeb.Auth.Schemas.ResendConfirmationEmailRequest, as: Request

  tags(["auth"])

  operation(:create,
    summary: "Resend user confirmation email",
    operation_id: "ResendConfirmationEmail",
    request_body: Request.request(),
    responses: %{
      ok: SuccessResponse.response("Success"),
      unprocessable_entity: SchemaErrorResponse.response()
    }
  )

  def create(%{body_params: %Request{email: email}}, _params) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    :ok
  end

  operation(:update,
    summary: "Confirm user account",
    operation_id: "ConfirmUser",
    parameters: [
      token: [
        in: :path,
        type: :string,
        required: true
      ]
    ],
    responses: %{
      ok: SuccessResponse.response(),
      bad_request: GenericErrorResponse.response("Error"),
      unprocessable_entity: SchemaErrorResponse.response()
    }
  )

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def update(_conn, %{token: token}) do
    case Accounts.confirm_user(token) do
      {:ok, _} ->
        :ok

      :error ->
        {:error, :bad_request, "User confirmation link is invalid or it has expired."}
    end
  end
end
