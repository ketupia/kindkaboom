defmodule Kindkaboom.Secrets do
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], Kindkaboom.Accounts.User, _opts) do
    Application.fetch_env(:kindkaboom, :token_signing_secret)
  end
end
