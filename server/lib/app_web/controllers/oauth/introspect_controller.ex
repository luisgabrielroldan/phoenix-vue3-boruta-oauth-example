defmodule AppWeb.Oauth.IntrospectController do
  @behaviour Boruta.Oauth.IntrospectApplication

  use AppWeb, :controller

  alias Boruta.Oauth.Error
  alias Boruta.Oauth.IntrospectResponse
  alias AppWeb.Oauth.OauthJSON

  def oauth_module, do: Application.get_env(:app, :oauth_module, Boruta.Oauth)

  def introspect(%Plug.Conn{} = conn, _params) do
    conn |> oauth_module().introspect(__MODULE__)
  end

  @impl Boruta.Oauth.IntrospectApplication
  def introspect_success(conn, %IntrospectResponse{} = response) do
    conn
    |> put_view(OauthJSON)
    |> render(:introspect, response: response)
  end

  @impl Boruta.Oauth.IntrospectApplication
  def introspect_error(conn, %Error{
        status: status,
        error: error,
        error_description: error_description
      }) do
    conn
    |> put_status(status)
    |> put_view(OauthJSON)
    |> render(:error, error: error, error_description: error_description)
  end
end
