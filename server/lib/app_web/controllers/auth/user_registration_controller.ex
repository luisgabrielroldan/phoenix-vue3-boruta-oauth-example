defmodule AppWeb.Auth.UserRegistrationController do
  use AppWeb, :api_controller

  alias App.Accounts
  alias AppWeb.Auth.Schemas.UserRegistrationRequest, as: Request
  alias AppWeb.Shared.Schemas.{SchemaErrorResponse, SuccessResponse}

  tags(["auth"])

  operation(:create,
    summary: "Register a new user",
    operationId: "RegisterUser",
    request_body: Request.request(),
    responses: %{
      ok: SuccessResponse.response("Succes"),
      bad_request: SchemaErrorResponse.response(),
      unprocessable_entity: SchemaErrorResponse.response()
    }
  )

  def create(%{body_params: %Request{user: user_params}}, _params) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        :ok

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, :bad_request, changeset}
    end
  end
end
