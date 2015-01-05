defmodule DigOc.Supervisor do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
                worker(DigOc.EM, [[name: DigOc.EM]])
               ]

    opts = [strategy: :one_for_one, name: DigOc.Supervisor]
    supervisor_result = Supervisor.start_link(children, opts)

    if Mix.env == :dev do
      GenEvent.add_handler DigOc.event_manager, DigOc.EM.Monitor, []
    end
    
    supervisor_result
  end
end