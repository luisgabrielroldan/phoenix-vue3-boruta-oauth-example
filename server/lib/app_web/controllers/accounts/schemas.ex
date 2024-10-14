defmodule AppWeb.Accounts.Schemas do
  alias OpenApiSpex.Schema

  defmodule UserSettingsResponse do
    use AppWeb, :api_schema

    def_response(%Schema{
      title: "UserSettingsResponse",
      type: :object,
      properties: %{
        email: %Schema{type: :string, format: :email}
      },
      required: [:email]
    })
  end

  defmodule UserSettingsUpdateRequest do
    use AppWeb, :api_schema

    def_request(%{
      title: "UserSettingsUpdateRequest",
      type: :object,
      properties: %{
        action: %Schema{
          type: :string,
          enum: ["update_email", "update_password"]
        },
        current_password: %Schema{type: :string},
        user: %Schema{
          type: :object,
          properties: %{
            email: %Schema{type: :string, format: :email},
            password: %Schema{type: :string},
            password_confirmation: %Schema{type: :string}
          }
        }
      },
      required: [:action]
    })
  end
end
