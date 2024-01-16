function v_copy (pos, output)
  if output == nil then
    output = {}
  end
  output.x = pos.x
  output.y = pos.y
  output.z = pos.z

  return output
end
function north (pos, amount, output)
  output = v_copy(pos, output)
  if amount == nil then
    amount = 1
  end
  output.z = output.z + amount
  return output
end
function south (pos, amount, output)
  output = v_copy(pos, output)
  if amount == nil then
    amount = 1
  end
  output.z = output.z - amount
  return output
end
function east (pos, amount, output)
  output = v_copy(pos, output)
  if amount == nil then
    amount = 1
  end
  output.x = output.x + amount
  return output
end
function west (pos, amount, output)
  output = v_copy(pos, output)
  if amount == nil then
    amount = 1
  end
  output.x = output.x - amount
  return output
end
function bottom (pos, amount, output)
  output = v_copy(pos, output)
  if amount == nil then
    amount = 1
  end
  output.y = output.y - amount
  return output
end
function top (pos, amount, output)
  output = v_copy(pos, output)
  if amount == nil then
    amount = 1
  end
  output.y = output.y + amount
  return output
end

local listH = 0.75
local labelH = 0.25

function register_craft_coal ()
  minetest.register_craft({
    type = "cooking",
    output = "default:coal_lump",
    recipe = "default:pine_tree",
    cooktime = 3.0,
  })
end

function register_stone_pick_sharp ()
  minetest.register_tool("repcraft:pick_stone_sharp", {
    description = "Sharp Stone Pickaxe",
    inventory_image = "repcraft_tool_stonepicksharp.png",
    tool_capabilities = {
      full_punch_interval = 1.3,
      max_drop_level=0,
      groupcaps={
        cracky = {times={[2]=0.8, [3]=0.7}, uses=30, maxlevel=1},
      },
      damage_groups = {fleshy=3},
    },
    sound = {breaks = "default_tool_breaks"},
    groups = {pickaxe = 1}
  })
  minetest.register_craft({
    type = "cooking",
    output = "repcraft:pick_stone_sharp",
    recipe = "default:pick_stone",
    cooktime = 40.0,
  })
end

function register_craft_flint ()
  minetest.register_craft({
    type = "cooking",
    output = "default:flint",
    recipe = "default:gravel",
    cooktime = 20.0,
  })
end

function register_stone_axe_sharp ()
  minetest.register_tool("repcraft:axe_stone_sharp", {
    description = "Sharp Stone Axe",
    inventory_image = "repcraft_tool_stoneaxesharp.png",
    tool_capabilities = {
      full_punch_interval = 1.2,
      max_drop_level=0,
      groupcaps={
        choppy={times={[1]=2.00, [2]=1.00, [3]=0.9}, uses=30, maxlevel=1},
      },
      damage_groups = {fleshy=3},
    },
    sound = {breaks = "default_tool_breaks"},
    groups = {axe = 1}
  })
  minetest.register_craft({
    output = "repcraft:axe_stone_sharp",
    type = "shaped",
    recipe = {
      { "default:flint","default:flint","" },
      { "default:flint","default:stick","" },
      { "","default:stick","" }
    }
  })
end

function inv_get_any_item (inv, list)
  if inv == nil then
    return nil
  end

  if list == nil then
    list = "main"
  end

  local items = inv:get_list(list)
  
  if items == nil then
    return nil
  end
  
  local item = nil
  for i,v in ipairs(items) do
    if items[i]:get_name() ~= "" then
      item = items[i]      
      break
    end
  end

  return item
end

function register_sorter ()
  minetest.register_node("repcraft:sorter", {
    description = "Item Sorter",
    tiles = {"default_stone.png"},
    groups = { cracky = 3, stone = 2},
    drawtype = "nodebox",
    sunlight_propagates = true,
    node_box = {
      type = "fixed",
      fixed = {{
        -0.4, 0.2, -0.5,
        0.4, 0.5, -0.4,
      }, {
        -0.4, 0.2, 0.5,
        0.4, 0.5, 0.4,
      },{
        -0.5, 0.2, -0.5,
        -0.4, 0.5, 0.5,
      }, {
        0.5, 0.2, -0.5,
        0.4, 0.5, 0.5,
      },{
        -0.4, 0.1, -0.4,
        0.4, 0.2, 0.4,
      }, {
        -0.1, -0.5, -0.1,
        0.1, 0.1, 0.1,
      }, {
        -0.5, -0.05, -0.05,
        0.5, 0.05, 0.05,
      }, {
        -0.05, -0.05, -0.5,
        0.05, 0.05, 0.5,
      }}
    },
    on_construct = function(pos)
      local meta = minetest.get_meta(pos)
		  local inv = meta:get_inventory()
      inv:set_size("main", 1)
      inv:set_size("filter", 4)

      -- meta:set_string("formspec",
      --   "formspec_version[4]"..
      --   "size[9.75,8]"..
      --   "bgcolor[#000]".. --bgcolor[<bgcolor>;<fullscreen>;<fbgcolor>]
      --   "label[0,0.1;Item Sorter (" .. pos.x .. "," .. pos.y .. "," .. pos.z ..")]" ..
      --   "label[0,0.5;Input Item]" ..
      --   "label[4,0.5;Filter items will be used to compare to input item only]" ..
      --   "list[context;main;0,1;1,1;]" ..
      --   "label[2,1.5;Filter (N S E W)]" ..
      --   "list[context;filter;0,2.25;4,1;]" ..
      --   "label[5.5,2.75;Your Inventory]" ..
      --   "list[current_player;main;0,3.5;8,4;]"..
      --   "no_prepend[]"
      -- )
      meta:set_string("formspec",
        "formspec_version[6]" ..
        "size[10.5,10]" ..
        "list[context;main;4.8,1.2;1,1;]" ..
        "list[context;filter;2.9,3.2;4,1;]" ..
        "list[current_player;main;0.4,5.2;8,4;]" ..
        "label[4.7,0.8;Input Inv]" ..
        "label[3.8,2.7;Filter Inv (N S E W)]" ..
        "label[4.7,4.7;Your Inv]" ..
        "label[3.8,0.2;Item Sorter at { " .. minetest.formspec_escape(tostring(--[[${]]pos.x--[[}]])) .. "\\, " .. minetest.formspec_escape(tostring(--[[${]]pos.y--[[}]])) .. "\\, " .. minetest.formspec_escape(tostring(--[[${]]pos.z--[[}]])) .. " }]"
      )

    end,
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
      
      local playername = clicker:get_player_name()
      
      local meta = minetest.get_meta(pos)
      local formspec = meta:get_string("formspec")

      minetest.show_formspec(
        playername,
        "repcraft:sorter",
        formspec
      )
    end,
  })

  minetest.register_abm({
    label = "repcraft:sorter sorting",
    nodenames = { "repcraft:sorter" },
    interval = 1,
    chance = 1,

    -- min_y = -1000,
    -- max_y = 1000,

    catch_up = false,

    action = function (pos, node, active_object_count, active_object_count_wider)
      --get the sorter inventory
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      
      local tp = nil

      --the output inventory (side block or bottom)
      local oinv = nil

      --if slot open, see if inventory above us can give us an itemstack
      if inv:is_empty("main") then
        tp = top(pos)
        oinv = minetest.get_meta(
          tp
        ):get_inventory()

        local input = inv_get_any_item(oinv)
        if input ~= nil then
          -- minetest.chat_send_all("top not empty, got item: " .. input:get_name())
          if oinv:room_for_item("main", input) then
            --remove from first inv
            oinv:remove_item("main", input)
            --add to second
            inv:add_item("main", input)
            --don't process sorting this step
            return
          end
        end
      end
      
      --get the sorter input item (only one slot)
      local input = inv:get_list("main")[1]

      --if filter is empty, just move to bottom
      if inv:is_empty("filter") then
        tp = bottom(pos)
        oinv = minetest.get_meta(
          tp
        ):get_inventory()
        if oinv:room_for_item("main", input) then
          inv:remove_item("main", input)
          oinv:add_item("main", input)
          return
        end
        return
      end

      --get name of input item
      local name_i = input:get_name()

      --get list of filter items
      local filter = inv:get_list("filter")

      --get names of filter items
      local name_n = filter[1]:get_name()
      local name_s = filter[2]:get_name()
      local name_e = filter[3]:get_name()
      local name_w = filter[4]:get_name()

      --calculate a block pos (side or bottom) based on filter item matching
      if name_i == name_n then
        tp = north(pos)
      elseif name_i == name_s then
        tp = south(pos)
      elseif name_i == name_e then
        tp = east(pos)
      elseif name_i == name_w then
        tp = west(pos)
      else
        tp = bottom(pos)
      end

      --get the inventory for the side
      oinv = minetest.get_meta(
        tp
      ):get_inventory()

      --checks if the inventory exists + has room for the item
      if oinv:room_for_item("main", input) then
        --remove from first inv
        inv:remove_item("main", input)
        --add to second
        oinv:add_item("main", input)
        return
      end

    end,
  })

  minetest.register_craft({
    output = "repcraft:sorter",
    type = "shaped",
    recipe = {
      { "default:cobble","","default:cobble" },
      { "default:cobble","","default:cobble" },
      { "default:cobble","default:cobble","default:cobble" }
    }
  })
end

function main ()
  register_craft_coal()
  register_stone_pick_sharp()
  register_craft_flint()
  register_stone_axe_sharp()
  register_sorter()
end

main()
