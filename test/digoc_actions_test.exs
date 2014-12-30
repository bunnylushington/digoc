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

  test "droplet actions" do
    res = DigOc.droplet!(:new, info)
    id = res.droplet.id
    assert is_integer(id)
    DigOc.wait_for_status(id, :active)
    
    del_res = DigOc.droplet!(:delete, id)
    IO.puts inspect del_res

    IO.puts inspect DigOc.droplet!(id)

  end
  

end