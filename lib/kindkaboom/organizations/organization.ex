defmodule Kindkaboom.Organizations.Organization do
  use Ash.Resource,
    otp_app: :kindkaboom,
    domain: Kindkaboom.Organizations,
    notifiers: [Ash.Notifier.PubSub],
    # TODO - johnny, johnhitz, kevin, maxhero
    # authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer

  postgres do
    table "organizations"
    repo Kindkaboom.Repo
  end

  actions do
    defaults [
      :read,
      :destroy,
      create: [:name, :description, :logo_url, :website],
      update: [:name, :description, :logo_url, :website]
    ]
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :description, :string do
      public? true
    end

    attribute :logo_url, :string do
      allow_nil? false
      public? true
    end

    attribute :website, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end
end
