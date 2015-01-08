defmodule DigOc.Image do

  import DigOc, only: [response: 1, event_manager: 0, wait_time: 0]
  import DigOc.Request, only: [putreq: 2, delreq: 1, req: 1, postreq: 2]


  @doc """
  Request that an image be deleted.
  """
  def delete(id), do: delreq("images/#{ id }")

  
  @doc """
  Like `delete/1` but returns the response body only.
  """
  def delete!(id), do: delete(id) |> response


  @doc """
  Request that an image be updated.
  """
  def update(id, new_name), do: putreq("images/#{ id }", %{ name: new_name })

  
  @doc """
  Like `update/2` but returns the response body only.
  """
  def update!(id, new_name), do: update(id, new_name) |> response

  
  @doc """
  Request the image be transfered to a different region.
  """
  def transfer(id, region_slug) do
    res = postreq("images/#{ id }/actions", %{ type: :transfer, 
                                               region: region_slug })
    action_id = DigOc.Droplet.feature_from_action(res, :id)
    spawn(__MODULE__, :wait_for_action, [id, action_id])
    res
  end

  
  @doc """
  Like `transfer/2` but returns only the response body.
  """
  def transfer!(id, region_slug), do: transfer(id, region_slug) |> response


  @doc """
  Request the action object associated with the image and action.
  """
  def action(image_id, action_id) do
    req("images/#{ image_id }/actions/#{ action_id }")
  end

  
  @doc """
  Like `action/2` but return only the response body.
  """
  def action!(image_id, action_id), do: action(image_id, action_id) |> response


  @doc """ 
  Like `DigOc.Droplet.wait_for_action/2` but for an image, not droplet, action.
  """
  def wait_for_action(image_id, action_id) do
    action = action!(image_id, action_id)
    if action.action.status !== "in-progress" do
      payload = {:action_finished, image_id, action_id, action.action}
      GenEvent.sync_notify(event_manager, payload)
    else
      :timer.sleep(wait_time)
      wait_for_action(image_id, action_id)
    end
  end
    

end