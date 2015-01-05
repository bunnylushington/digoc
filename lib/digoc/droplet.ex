defmodule DigOc.Droplet do

  import DigOc, only: [response: 1, event_manager: 0, wait_time: 0]
  import DigOc.Request, only: [req: 1, postreq: 2]
  require DigOc.Macros.Droplet, as: M

  # -- Actions send a POST and get an action obj back.  These all
  # -- register with wait_for_action/2 which posts an event when that
  # -- action object no longer has the status "in-progress."
  M.make_action(:power_cycle)
  M.make_action(:reboot)
  M.make_action(:shutdown)
  M.make_action(:power_off) 
  M.make_action(:power_on) 
  M.make_action(:password_reset) 
  M.make_action(:enable_ipv6) 
  M.make_action(:enable_private_networking) 
  M.make_action(:migrate_droplet) 
  M.make_action(:disable_backups) 
  M.make_action(:restore, :image) 
  M.make_action(:resize, :size) 
  M.make_action(:rebuild, :image) 
  M.make_action(:rename, :name) 
  M.make_action(:change_kernel, :kernel) 
  M.make_action(:snapshot, :name) 

  defp task(id, action, extra \\ %{}) do
    map = Map.merge( %{ type: action }, extra )
    res = postreq("droplets/#{ id }/actions", map) 
    action_id = feature_from_action(res, :id)
    spawn(__MODULE__, :wait_for_action, [id, action_id])
    res
  end    

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
