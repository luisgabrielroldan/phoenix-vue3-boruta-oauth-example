Mox.defmock(Boruta.OauthMock, for: Boruta.OauthModule)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(App.Repo, :manual)
