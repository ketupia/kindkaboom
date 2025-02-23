defmodule Kindkaboom.Organizations.Volunteer do
  use Ash.Resource,
    otp_app: :kindkaboom,
    domain: Kindkaboom.Organizations,
    notifiers: [Ash.Notifier.PubSub],
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer

  postgres do
    table "volunteers"
    repo Kindkaboom.Repo
  end

  actions do
    defaults [
      :read,
      :destroy,
      create: [:name, :volunteer_interests],
      update: [:name, :volunteer_interests]
    ]
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :volunteer_interests, :string do
      allow_nil? false
      public? true
    end

    attribute :address_1, :string
    attribute :address_2, :string
    attribute :city, :string
    attribute :state, :string
    attribute :post_code, :string
    timestamps()
  end
end
