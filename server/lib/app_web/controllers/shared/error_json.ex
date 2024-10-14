defmodule AppWeb.ErrorJSON do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on JSON requests.

  See config/config.exs.
  """

  # If you want to customize a particular status code,
  # you may add your own clauses, such as:
  #
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".

  alias Ecto.Changeset

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  def error(%{message: message}) do
    %{success: false, message: message}
  end

  def error(%{changeset: changeset}) do
    errors =
      changeset
      |> Changeset.traverse_errors(&translate_error/1)
      |> Enum.map(fn {field, err_list} ->
        detail =
          Enum.map_join(err_list, ", ", fn err ->
            err
            |> String.capitalize()
            |> Kernel.<>(".")
          end)

        %{
          title: "Invalid value",
          detail: detail,
          source: %{pointer: "/#{field}"}
        }
      end)

    %{success: false, errors: errors}
  end

  defp translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(AppWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(AppWeb.Gettext, "errors", msg, opts)
    end
  end
end
