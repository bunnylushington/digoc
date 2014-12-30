defmodule DigOcImagesTest do
  use ExUnit.Case

  test "list/get images" do
    assert hd(DigOc.images!.images) |> is_map
    assert hd(DigOc.images!(:distribution).images) |> is_map
    
    app_images = DigOc.images!("applications").images
    assert hd(app_images) |> is_map

    img = Enum.filter(app_images, fn(x) -> x.slug && x.id end) |> hd
    assert DigOc.image!(img.slug) == DigOc.image!(img.id)
  end

end