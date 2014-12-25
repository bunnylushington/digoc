defmodule DigOc.Pretty do

  def droplets(hash) when is_map(hash), do: droplets(hash.droplets)

  def droplets(list) do
    for d <- Enum.sort(list, &(&1.name < &2.name)), do: print_droplet(d)
  end

  def print_droplet(d) do
    for x <- [IO.ANSI.yellow, d.name, IO.ANSI.reset, padding(d.name, 10), 
              d.id, padding(d.id, 9),
              d.memory, padding(d.memory, 5),
              d.disk, padding(d.disk, 4),
              d.vcpus, padding(d.vcpus, 3),
              d.status, padding(d.status, 12),
              d.region.slug, padding(d.region.slug, 6),
              d.image.distribution, padding(d.image.distribution, 8),
              "\n" ], do: IO.write x
  end

  defp padding(target, spaces) do
    String.duplicate(" ", (spaces - String.length(to_string(target))))
  end

end