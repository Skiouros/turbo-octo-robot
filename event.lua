local Event = {}
Event.__index = Event

function Event.new()
    self = {}
    self.listeners = {}
    setmetatable(self, Event)
    return self
end

function Event:add(action)
    local id = {}
    self.listeners[id] = action
    return id
end

function Event:remove(id)
    self.listeners[id] = nil
end

function Event:dispatch(...)
    for id, action in pairs(self.listeners) do
        action(...)
    end
end

function Event:__call(...)
    self:dispatch(...)
end

return Event
