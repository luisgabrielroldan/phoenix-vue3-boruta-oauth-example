defmodule AppWeb.Utils.ApiSchema do
  @moduledoc false
  alias OpenApiSpex.Schema

  defmacro def_schema(schema) do
    quote do
      OpenApiSpex.schema(unquote(schema))
    end
  end

  defmacro def_request(schema) do
    quote do
      OpenApiSpex.schema(unquote(schema))

      def request(opts \\ []) do
        description = Keyword.get(opts, :description, "")
        content_type = Keyword.get(opts, :content_type, "application/json")
        required = Keyword.get(opts, :required, true)

        {description, content_type, __MODULE__, [required: required]}
      end
    end
  end

  defmacro def_response(data_schema \\ nil) do
    extra_properties =
      case data_schema do
        nil ->
          Macro.escape(%{})

        _ ->
          quote do
            %{data: unquote(data_schema)}
          end
      end

    quote do
      require OpenApiSpex

      @properties Map.merge(%{success: %Schema{type: :boolean}}, unquote(extra_properties))

      OpenApiSpex.schema(%{
        type: :object,
        properties: @properties,
        required: [:success]
      })

      def response(description \\ "Response", opts \\ []) do
        content_type = Keyword.get(opts, :content_type, "application/json")

        {description, content_type, __MODULE__}
      end
    end
  end
end
