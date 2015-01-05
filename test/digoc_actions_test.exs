defmodule DigOcActionsTest do
  use ExUnit.Case

  @timeout 60000
  @tag timeout: 60000
  
  defp info do
    %{ name: "test-#{ System.get_pid }",
       region: "nyc3",
       size: "512mb",
       image: "coreos-beta",
       ssh_keys: [164439],
       backups: false,
       ipv6: true,
       user_data: "a user data string",
       private_networking: true }
  end

  defmodule Receiver do
    use GenEvent
    def handle_event(event, parent) do
      send parent, event
      {:ok, parent}
    end
  end

  setup do
    GenEvent.add_mon_handler(DigOc.event_manager, DigOcActionsTest.Receiver,
                                                                   self())
  end

  test "droplet actions" do

    # -- create.
    IO.puts "Creating new droplet."
    res = DigOc.Droplet.new!(info)
    id = res.droplet.id
    assert is_integer(id)
    assert_receive {:achieved_status, id, :active}, @timeout
 
    # -- test make_action macro with one arg
    IO.puts "Powercycling droplet."
    res = DigOc.Droplet.power_cycle!(id)
    action_id = res.action.id
    assert res.action.resource_id == id
    assert res.action.type == "power_cycle"
    assert_receive {:action_finished, id, action_id, _}, @timeout

    # -- test make_action macro with two args
    IO.puts "Renaming droplet."
    res = DigOc.Droplet.rename!(id, "FancyName")
    action_id = res.action.id
    assert res.action.resource_id == id
    assert res.action.type == "rename"
    assert_receive {:action_finished, id, action_id, _}, @timeout

    # -- destroy.
    IO.puts "Destroying droplet."
    {_, "", headers} = DigOc.droplet(:delete, id)
    assert headers["Status"] == "204 No Content"
  end
  

end