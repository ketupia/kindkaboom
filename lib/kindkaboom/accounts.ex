defmodule Kindkaboom.Accounts do
  use Ash.Domain, otp_app: :kindkaboom, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource Kindkaboom.Accounts.User
    resource Kindkaboom.Accounts.Token
  end
end
