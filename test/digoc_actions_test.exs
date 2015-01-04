defmodule DigOcActionsTest do
  use ExUnit.Case

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
    res = DigOc.droplet!(:new, info)
    id = res.droplet.id
    assert is_integer(id)
    assert_receive {:achieved_status, id, :active}, 60000
    
    {_, "", headers} = DigOc.droplet(:delete, id)
    assert headers["Status"] == "204 No Content"
  end
  

end