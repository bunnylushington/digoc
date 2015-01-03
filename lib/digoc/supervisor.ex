defmodule DigOc.Supervisor do
  use Application

  @em_name DigOc.EM

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
                worker(DigOc.EM, [[name: DigOc.EM]])
               ]

    opts = [strategy: :one_for_one, name: DigOc.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    GenEvent.add_handler @em_name, DigOc.EM.Monitor, []
    {:ok, pid}
  end
end