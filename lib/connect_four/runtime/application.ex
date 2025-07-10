defmodule ConnectFour.Runtime.Application do

  @super_name ConnectFourGameStarter
  use Application
  @registry :connectfour_server_registry

  def start(_type, _args) do

    supervisor_spec = [
      {Phoenix.PubSub, name: ConnectFour.PubSub},
      { DynamicSupervisor, strategy: :one_for_one, name: @super_name },
      {Registry, [keys: :unique, name: @registry]},
    ]

    Supervisor.start_link(supervisor_spec, strategy: :one_for_one)
  end

  def start_game(uid) do
    DynamicSupervisor.start_child(@super_name, { ConnectFour.Runtime.Server, uid})
  end
end
