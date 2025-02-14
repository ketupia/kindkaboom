defmodule KindkaboomWeb.UserDashboardLive do
  use KindkaboomWeb, :live_view

  on_mount({KindkaboomWeb.LiveUserAuth, :live_user_required})

  @impl true
  def render(assigns) do
    ~H"""
    <h1>My Dashboard</h1>
    """
  end
end
