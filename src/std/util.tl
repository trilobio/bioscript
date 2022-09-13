--[[---------------------------------------------------------------------------

                            Basic functions

---------------------------------------------------------------------------]]--

local record util
  uuid: function(): string
end

util.uuid = function(): string
  local u, _ = string.gsub('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', '[xy]', function (c:string): string
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
  return u
end

return util
