defmodule DigOcImagesTest do
  use ExUnit.Case

  @moduletag timeout: 300000
  @timeout 60000

  def info do
    %{ name: "test-#{ System.get_pid }-img",
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
    GenEvent.add_mon_handler(DigOc.event_manager,
                                   DigOcImagesTest.Receiver, self())
    on_exit fn -> GenEvent.remove_handler(DigOc.event_manager,
                                                DigOcImagesTest.Receiver, [])
            end
  end

  test "list/get images" do
    assert hd(DigOc.images!.images) |> is_map
    assert hd(DigOc.images!(:distribution).images) |> is_map
    
    app_images = DigOc.images!("applications").images
    assert hd(app_images) |> is_map

    img = Enum.filter(app_images, fn(x) -> x.slug && x.id end) |> hd
    assert DigOc.image!(img.slug) == DigOc.image!(img.id)
  end

  test "create, rename, delete image" do
    res = DigOc.Droplet.new!(info)
    id = res.droplet.id
    assert is_integer(id)
    assert_receive {:achieved_status, id, :active}, @timeout

    DigOc.Droplet.power_off(id)
    assert_receive {:action_finished, id, _, _}, @timeout

    snapshot = "image test #{ System.get_pid }"
    DigOc.Droplet.snapshot(id, snapshot)
    assert_receive {:action_finished, id, _, _}, @timeout

    image = Enum.filter(DigOc.images!(1000).images, 
      fn(x) -> x.name == snapshot end) |> hd
    
    DigOc.Image.update!(image.id, "fancy new name")
    second_image = DigOc.image!(image.id)
    assert second_image.image.name == "fancy new name"

    DigOc.Image.delete(image.id)
    DigOc.Droplet.delete(id)
  end

end