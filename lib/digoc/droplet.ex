defmodule DigOc.Droplet do

  import DigOc, only: [response: 1, event_manager: 0, wait_time: 0]
  import DigOc.Request, only: [req: 1, postreq: 2, putreq: 2, delreq: 1]

  def power_cycle(id) do
    res = postreq("droplets/#{ id }/actions", %{ type: :power_cycle }) 
    action_id = feature_from_action(res, :id)
    spawn(__MODULE__, :wait_for_action, [id, action_id])
    res
  end

  def power_cycle!(id), do: power_cycle(id) |> response

  def action(droplet_id, action_id) do
    req("droplets/#{ droplet_id }/actions/#{ action_id }")
  end

  def action!(droplet_id, action_id) do
    action(droplet_id, action_id) |> response
  end

  def wait_for_action(droplet_id, action_id) do
    action = action!(droplet_id, action_id)
    if action.action.status !== "in-progress" do
      payload = {:action_finished, droplet_id, action_id, action.action}
      GenEvent.sync_notify(event_manager, payload)
    else
      :timer.sleep(wait_time)
      wait_for_action(droplet_id, action_id)
    end
  end

  def feature_from_action(res, f) when is_map(res), do: res.action[f]
  def feature_from_action({_, body, _}, f), do: body.action[f]

end
