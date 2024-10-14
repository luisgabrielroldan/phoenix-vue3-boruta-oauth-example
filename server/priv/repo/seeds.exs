alias App.Accounts.User
alias App.Repo

Repo.insert!(%User{
  email: "admin@example.com",
  hashed_password: Bcrypt.hash_pwd_salt("password")
})

id = "deadb33f-0000-0000-0000-123456789abc"
secret = SecureRandom.hex(64)
private_key = JOSE.JWK.generate_key({:rsa, 2048, 65_537})
public_key = JOSE.JWK.to_public(private_key)
{_type, public_pem} = JOSE.JWK.to_pem(public_key)
{_type, private_pem} = JOSE.JWK.to_pem(private_key)

%Boruta.Ecto.Client{}
|> Boruta.Ecto.Client.create_changeset(%{
  # OAuth client_id
  id: id,
  # OAuth client_secret
  secret: secret,
  # Display name
  name: "Web Client",
  # one day
  access_token_ttl: 60 * 60 * 24,
  # one minute
  authorization_code_ttl: 60,
  # one month
  refresh_token_ttl: 60 * 60 * 24 * 30,
  # one day
  id_token_ttl: 60 * 60 * 24,
  # ID token signature algorithm, defaults to "RS512"
  id_token_signature_alg: "RS256",
  # userinfo signature algorithm, defaults to nil (no signature)
  userinfo_signed_response_alg: "RS256",
  # OAuth client redirect_uris
  redirect_uris: ["http://redirect.uri"],
  # take following authorized_scopes into account (skip public scopes)
  authorize_scope: true,
  # scopes that are authorized using this client
  authorized_scopes: [%{name: "a:scope"}],
  # client supported grant types
  supported_grant_types: [
    # "client_credentials",
    "password",
    # "authorization_code",
    "refresh_token",
    # "implicit",
    "revoke",
    "introspect"
  ],
  # PKCE enabled
  pkce: false,
  # do not require client_secret for refreshing tokens
  public_refresh_token: true,
  # do not require client_secret for revoking tokens
  public_revoke: true,
  # see OAuth 2.0 confidentiality (requires client secret for some flows)
  confidential: false,
  # activable client authentication methods
  token_endpont_auth_methods: [
    "client_secret_basic",
    "client_secret_post",
    "client_secret_jwt",
    "private_key_jwt"
  ],
  # associated to authentication methods, the algorithm to use along
  token_endpoint_jwt_auth_alg: "RS256",
  # pem public key to be used with `private_key_jwt` authentication method
  jwt_public_key: nil
})
|> Boruta.Ecto.Client.key_pair_changeset(%{
  public_key: public_pem,
  private_key: private_pem
})
|> Boruta.Config.repo().insert!()
|> IO.inspect()
