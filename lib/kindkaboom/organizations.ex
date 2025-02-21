defmodule Kindkaboom.Organizations do
  use Ash.Domain,
    otp_app: :kindkaboom

  resources do
    resource Kindkaboom.Organizations.Organization
  end
end
