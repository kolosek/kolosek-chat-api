defmodule CompanyApi.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(CompanyApi.Repo, []),
      supervisor(CompanyApiWeb.Endpoint, []),
      supervisor(Task.Supervisor, [[name: EmailSupervisor]]),
      worker(CompanyApi.ChannelUsers, [%{}]),
      worker(CompanyApi.ChannelSessions, [%{}])
    ]

    opts = [strategy: :one_for_one, name: CompanyApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    CompanyApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
