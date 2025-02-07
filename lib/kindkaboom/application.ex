defmodule Kindkaboom.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Oban,
       AshOban.config(
         Application.fetch_env!(:kindkaboom, :ash_domains),
         Application.fetch_env!(:kindkaboom, Oban)
       )},
      KindkaboomWeb.Telemetry,
      Kindkaboom.Repo,
      {DNSCluster, query: Application.get_env(:kindkaboom, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Kindkaboom.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Kindkaboom.Finch},
      # Start a worker by calling: Kindkaboom.Worker.start_link(arg)
      # {Kindkaboom.Worker, arg},
      # Start to serve requests, typically the last entry
      KindkaboomWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :kindkaboom]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Kindkaboom.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KindkaboomWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
