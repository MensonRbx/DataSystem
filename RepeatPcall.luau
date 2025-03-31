local MAX_PCALL_ATTEMPTS  = 5
local DEBUG_MODE = true

local function repeatPcall(callback: any, ...: any): (any)
        local count = 0
        repeat
                local success, val = pcall(callback, ...)
                if success then
                        return val, true
                end
                count += 1
                task.wait()
        until count > MAX_PCALL_ATTEMPTS

        if DEBUG_MODE then
                warn("pcall failed after max attempts!")
        end

        return 
end

return repeatPcall
