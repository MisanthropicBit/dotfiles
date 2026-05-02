--- A fixed-size queue
---@class config.FixedSizedQueue<T>
---@field private _items table[]
---@field private _capacity integer
---@overload fun(self): table?
local FixedSizedQueue = {}

---@param capacity integer
---@return config.FixedSizedQueue
function FixedSizedQueue.new(capacity)
    local queue = {
        _items = {},
        _capacity = capacity,
    }

    return setmetatable(queue, {
        __index = FixedSizedQueue,
        __call = function(self)
            return ipairs(self._items)
        end,
    })
end

--- Clear all items
function FixedSizedQueue:clear()
    self._items = {}
end

--- Adds an item, overriding the oldest item if the queue is full
---@generic T
---@param item T
function FixedSizedQueue:push(item)
    table.insert(self._items, item)

    if #self._items > self._capacity then
        self:pop()
    end
end

--- Removes and returns the oldest item
---@generic T
---@return T?
function FixedSizedQueue:pop()
    return table.remove(self._items, 1)
end

--- Returns the newest item without removing it
---@generic T
---@return T?
function FixedSizedQueue:peek()
    return self._items[#self._items]
end

--- Returns a list of all the items in the queue
---@generic T
---@return T[]
function FixedSizedQueue:items()
    return self._items
end

---@return integer
function FixedSizedQueue:size()
    return #self._items
end

---@return integer
function FixedSizedQueue:capacity()
    return self._capacity
end

return FixedSizedQueue
