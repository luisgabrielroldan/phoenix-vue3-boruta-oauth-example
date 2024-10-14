defmodule AppWeb.Auth.Schemas do
  defmodule ResendConfirmationEmailRequest do
    use AppWeb, :api_schema

    def_request(%{
      title: "ResendConfirmationEmailRequest",
      type: :object,
      properties: %{
        email: %Schema{type: :string}
      },
      required: [:email]
    })
  end

  defmodule UserRegistrationRequest do
    use AppWeb, :api_schema

    def_request(%{
      title: "UserRegistrationRequest",
      type: :object,
      properties: %{
        user: %Schema{
          type: :object,
          properties: %{
            email: %Schema{type: :string, format: :email},
            password: %Schema{type: :string}
          },
          required: [:email, :password]
        }
      },
      required: [:user]
    })
  end

  defmodule ResetPasswordRequest do
    use AppWeb, :api_schema

    def_request(%{
      title: "ResetPasswordRequest",
      type: :object,
      properties: %{
        user: %Schema{
          type: :object,
          properties: %{
            email: %Schema{type: :string, format: :email}
          },
          required: [:email]
        }
      },
      required: [:user]
    })
  end

  defmodule ConfirmPasswordResetRequest do
    use AppWeb, :api_schema

    def_request(%{
      title: "ConfirmPasswordResetRequest",
      type: :object,
      properties: %{
        password: %Schema{type: :string}
      },
      required: [:password]
    })
  end
end
