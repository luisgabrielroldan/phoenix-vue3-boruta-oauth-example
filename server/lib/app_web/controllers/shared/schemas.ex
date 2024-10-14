defmodule AppWeb.Shared.Schemas do
  @moduledoc false

  defmodule SchemaErrors do
    use AppWeb, :api_schema

    def_schema(%{
      type: :array,
      items: %Schema{
        required: [:title, :source, :detail],
        type: :object,
        properties: %{
          title: %Schema{type: :string, example: "Invalid value"},
          source: %Schema{
            required: [:pointer],
            type: :object,
            properties: %{
              pointer: %Schema{
                type: :string,
                example: "/data/attributes/petName"
              }
            }
          },
          detail: %Schema{
            type: :string,
            example: "null value where string expected"
          }
        }
      }
    })
  end

  defmodule SuccessResponse do
    use AppWeb, :api_schema

    def_response()
  end

  defmodule GenericErrorResponse do
    use AppWeb, :api_schema

    def_schema(%{
      type: :object,
      properties: %{
        success: %Schema{type: :boolean},
        message: %Schema{type: :string}
      },
      required: [:success, :message]
    })

    def response(desc \\ "Generic error"), do: {desc, "application/json", __MODULE__}
  end

  defmodule SchemaErrorResponse do
    use AppWeb, :api_schema

    def_schema(%{
      type: :object,
      properties: %{
        success: %Schema{type: :boolean},
        errors: SchemaErrors
      },
      required: [:success, :errors]
    })

    def response(desc \\ "Schema error"), do: {desc, "application/json", __MODULE__}
  end
end
