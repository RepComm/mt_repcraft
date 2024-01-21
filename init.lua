function v_copy (pos, output)
  if output == nil then
    output = {}
  end
  output.x = pos.x
  output.y = pos.y
  output.z = pos.z

  return output
end

function v_add (output, addFrom)
  if output == nil then
    output = { x = 0, y = 0, z = 0}
  end
  output.x = output.x + addFrom.x
  output.y = output.y + addFrom.y
  output.z = output.z + addFrom.z

  return output
end
function v_sub (output, subFrom)
  if output == nil then
    output = { x = 0, y = 0, z = 0}
  end
  output.x = output.x - subFrom.x
  output.y = output.y - subFrom.y
  output.z = output.z - subFrom.z

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

local InvTransaction = {}
InvTransaction.__index = InvTransaction

function InvTransaction.new()
  local self = setmetatable({}, InvTransaction)
  self.src = nil
  self.dst = nil
  self.src_list = "main"
  self.dst_list = "main"
  self.stack = nil
  return self
end

--returns true if succeeded
--returns false, reason:string otherwise
function InvTransaction:transact()
  --assert both inventories exist
  if self.dst == nil then
    return false, "dst == nil"
  end
  if self.src == nil then
    return false, "src == nil"
  end

  --assert source and destination are different inventories
  if self.src == self.dst then
    return false, "src == dst"
  end

  --will get stack from src if .stack == nil
  local stack, discovered = self:get_stack()
  --assert there is a stack to move
  if stack == nil then
    return false, "stack == nil"
  end

  if not discovered then
    --assert item is from source
    if not self.src:contains_item(self.src_list, stack) then
      return false, "stack not in src"
    end
  end

  --assert there is room in destination
  if not self.dst:room_for_item(self.dst_list, stack) then
    return false, "no room for item in dst"
  end

  --remove item from source
  self.src:remove_item(self.src_list, stack)
  --add item to destination
  self.dst:add_item(self.src_list, stack)

  print("Transaction successful!")
  return true, ""
end

function InvTransaction:set_src(nsrc, list)
  self.src = nsrc
  if list ~= nil then
    self.src_list = list
  end
end

function InvTransaction:set_dst(ndst, list)
  self.dst = ndst
  if list ~= nil then
    self.dst_list = list
  end
end

function InvTransaction:set_stack(stack)
  self.stack = stack
end

--returns stack (may be nil), and true if stack was fetched from src
--false if stack could be from somewhere else
function InvTransaction:get_stack(stack)
  local discovered = false
  if self.stack == nil then
    self.stack = inv_get_any_item(self.src)
    discovered = true
  end
  return self.stack, discovered
end

function inv_from_pos(pos)
  return minetest.get_meta(pos):get_inventory()
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
      
      local ta = InvTransaction.new()

      local inv_s = inv_from_pos(pos)

      --if our input inv is empty
      if inv_s:is_empty("main") then
        local tpos = top(pos)
        local tnode = minetest.get_node(tpos)

        if tnode.name == "default:chest" then
          ta:set_src( inv_from_pos( tpos ) )
        end

      else
        --we're not empty, use our stack
        ta:set_src( inv_s )
      end

      local stack = ta:get_stack()

      if stack == nil then
        return
      end
      --get name of input item
      local name_i = stack:get_name()

      --get list of filter items
      local filter = inv_s:get_list("filter")

      --get names of filter items
      local name_n = filter[1]:get_name()
      local name_s = filter[2]:get_name()
      local name_e = filter[3]:get_name()
      local name_w = filter[4]:get_name()

      local tp = nil
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

      ta:set_dst( inv_from_pos( tp ) )

      --if transaction fails
      local success, reason = ta:transact()

      if success then
        -- minetest.chat_send_all(
        -- "transaction success, from: " .. ta.src:get_location().pos.y .. ",to: " .. ta.dst:get_location().pos.y
        -- )
      else
        --try setting item sorter as the destination
        ta:set_dst(inv_s)

        -- minetest.chat_send_all("transaction failed due to " .. reason)

        --try transaction again (fails if src == dst)
        if ta:transact() then
          -- minetest.chat_send_all("retry to sorter succeeded")
        end
        
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

function register_craft_bonemeal ()
  minetest.register_craft({
    output = "bonemeal:bonemeal 8",
    type = "shapeless",
    recipe = {
      "bonemeal:bone",
    },
  })
end

function register_scarecrow ()
  --farming:wheat_8
  minetest.register_node("repcraft:scarecrow", {
    description = "Scarecrow",
    groups = { cracky = 3, stone = 2},
    drawtype = "mesh",
    mesh = "scarecrow.obj",
    paramtype2 = "facedir",
    tiles = {
      "repcraft_scarecrow_wood.png",
      "repcraft_scarecrow_wheat.png",
      "repcraft_scarecrow_plad.png",
      "repcraft_scarecrow_jeans.png",
      "repcraft_scarecrow_hat.png",
    },
    selection_box = {
      type = "fixed",
      fixed = {
        -0.5, -0.5, -0.5,
        0.5, 1.5, 0.5
      }
    },
    collision_box = {
      type = "fixed",
      fixed = {
        -0.5, -0.5, -0.5,
        0.5, -0.4, 0.5
      }
    },
    sunlight_propagates = true,

    on_construct = function(pos)
      local meta = minetest.get_meta(pos)
		  local inv = meta:get_inventory()
      inv:set_size("main", 4)

      meta:set_string("formspec",
        "formspec_version[6]" ..
        "size[10.5,10]" ..
        "list[context;main;4.8,1.2;4,1;]" ..
        "list[current_player;main;0.4,5.2;8,4;]" ..
        "label[4.7,0.8;Scarecrow Inv]" ..
        "label[4.7,4.7;Your Inv]" ..
        "label[3.8,0.2;Scarecrow at { " .. minetest.formspec_escape(tostring(--[[${]]pos.x--[[}]])) .. "\\, " .. minetest.formspec_escape(tostring(--[[${]]pos.y--[[}]])) .. "\\, " .. minetest.formspec_escape(tostring(--[[${]]pos.z--[[}]])) .. " }]"
      )

    end,
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
      
      local playername = clicker:get_player_name()
      
      local meta = minetest.get_meta(pos)
      local formspec = meta:get_string("formspec")

      minetest.show_formspec(
        playername,
        "repcraft:scarecrow",
        formspec
      )
    end
  })

  minetest.register_abm({
    label = "repcraft:scarecrow harvesting",
    nodenames = { "repcraft:scarecrow" },
    interval = 30,--60,
    chance = 1,

    -- min_y = -1000,
    -- max_y = 1000,

    catch_up = false,

    action = function (pos, node, active_object_count, active_object_count_wider)
      local reach = 3
      local min = v_copy(pos)
      local max = v_copy(pos)
      
      min.x = min.x - reach
      min.y = min.y --- reach
      min.z = min.z - reach
      max.x = max.x + reach
      max.y = max.y --+ reach
      max.z = max.z + reach

      local p = v_copy(pos)

      local meta = minetest.get_meta(pos)
		  local inv = meta:get_inventory()

      for x=min.x,max.x do
        for y=min.y,max.y do
          for z=min.z,max.z do
            p.x = x
            p.y = y
            p.z = z
            
            local b = minetest.get_node(p)
            
            local harvest_name = "farming:wheat_8"
            local place_name = "farming:seed_wheat"

            if b.name == harvest_name then
              --drops as calculated by rarity
              local drops = minetest.get_node_drops(harvest_name)
              -- minetest.chat_send_all(dump(drops))
              local items = {}

              for i,drop in ipairs(drops) do
                
                local s = ItemStack(drop)
                items[#items+1] = s

                if not inv:room_for_item("main", s) then
                  return
                end
              end

              for i,item in ipairs(items) do
                inv:add_item("main", item)
              end

              --try remove seed from scarecrow inventory for placement
              --scarecrow will only replant if it has seed
              --players must place seed to jump start the process
              local place = inv:remove_item("main", ItemStack(place_name))
              if not place:is_empty() then
                minetest.set_node(p, {
                  name=place_name,
                  param2=1
                })
              end
            end
          end
        end
      end
      
      
    end,
  })

  minetest.register_craft({
    output = "repcraft:scarecrow",
    type = "shaped",
    recipe = {
      { "farming:wheat","group:stick","farming:wheat" },
      { "","group:stick","" },
      { "","group:wood","" }
    }
  })

end

function register_cobbleminer ()
  --farming:wheat_8
  minetest.register_node("repcraft:cobbleminer", {
    description = "Cobble Miner",
    groups = { cracky = 3, stone = 2},
    drawtype = "normal",
    paramtype = "light",
    light_source = 4,
    paramtype2 = "facedir",
    sunlight_propagates = false,
    tiles = {
      "repcraft_cobbleminer_sides.png",
      "repcraft_cobbleminer_sides.png",
      "repcraft_cobbleminer_sides.png",
      "repcraft_cobbleminer_sides.png",
      "repcraft_cobbleminer_sides.png",
      "repcraft_cobbleminer_front.png"
    },
    on_construct = function(pos)
      local meta = minetest.get_meta(pos)
		  local inv = meta:get_inventory()
      inv:set_size("main", 4)

      meta:set_string("formspec",
        "formspec_version[6]" ..
        "size[10.5,10]" ..
        "list[context;main;4.8,1.2;4,1;]" ..
        "list[current_player;main;0.4,5.2;8,4;]" ..
        "label[4.7,0.8;Cobbleminer Inv]" ..
        "label[4.7,4.7;Your Inv]" ..
        "label[3.8,0.2;Cobbleminer at { " .. minetest.formspec_escape(tostring(--[[${]]pos.x--[[}]])) .. "\\, " .. minetest.formspec_escape(tostring(--[[${]]pos.y--[[}]])) .. "\\, " .. minetest.formspec_escape(tostring(--[[${]]pos.z--[[}]])) .. " }]"
      )

    end,
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
      
      local playername = clicker:get_player_name()
      
      local meta = minetest.get_meta(pos)
      local formspec = meta:get_string("formspec")

      minetest.show_formspec(
        playername,
        "repcraft:cobbleminer",
        formspec
      )
    end
  })

  minetest.register_abm({
    label = "repcraft:cobbleminer mining",
    nodenames = { "repcraft:cobbleminer" },
    interval = 4,--60,
    chance = 1,

    -- min_y = -1000,
    -- max_y = 1000,

    catch_up = false,

    action = function (pos, node, active_object_count, active_object_count_wider)
      
      
      local v_dir = minetest.facedir_to_dir(node.param2)
      
      local v_target = v_copy(pos)
      v_add(v_target, v_dir)
      local b = minetest.get_node(v_target)
      
      if b.name ~= "default:cobble" and b.name ~= "default:stone" then
        return
      end


      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()

      local drops = minetest.get_node_drops(b.name)

      local items = {}

      for i,drop in ipairs(drops) do
        
        local s = ItemStack(drop)
        items[#items+1] = s

        if not inv:room_for_item("main", s) then
          return
        end
      end

      for i,item in ipairs(items) do
        inv:add_item("main", item)
      end

      minetest.set_node(v_target, {
        name="air"
      })
      
    end,
  })

  minetest.register_craft({
    output = "repcraft:cobbleminer",
    type = "shaped",
    recipe = {
      { "default:cobble","default:cobble","default:cobble" },
      { "default:cobble","repcraft:pick_stone_sharp","default:cobble" },
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
  register_craft_bonemeal()
  register_scarecrow()

  register_cobbleminer()
end

main()
