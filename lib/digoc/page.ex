defmodule DigOc.Page do
  
  import DigOc, only: [response: 1]
  import DigOc.Request, only: [req: 1]
  require DigOc.Macros.Page, as: P

  # -- Each direction (next, prev, &c.) has three related functions
  # -- defined:  
  #              direction?/1 returns a boolean
  #              direction/1 returns the HTTPoison response
  #              direction!/1 returns just the map of data

  P.navigate(:next)
  P.navigate(:prev)
  P.navigate(:first)
  P.navigate(:last)

  defp has_page?(data, page), do: Dict.has_key?(data.links.pages, page)
  
  defp get_page(data, page) do
    my_predicate = DigOc.predicate(page)
    if apply(__MODULE__, DigOc.predicate(page), [data]) do
      req(Dict.fetch!(data.links.pages, page))
    else
      raise("No bookmark for #{ page } page.")
    end
  end    

end