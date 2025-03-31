local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CacheSystem = require(ReplicatedStorage.Packages.cachesystem)
type TimedCache = CacheSystem.TimedCache

local repeatPcall = require(script.Parent.RepeatPcall)

local Store = {}
Store.__index = Store

type self = {
        name: string,
        _dataStore: DataStore,
        _cache: TimedCache -- So that network requests don't have to be made unnecessarily
}

export type Store = typeof(setmetatable({} :: self, Store))

function Store.Get(self: Store, key: string): ()
        if self._cache:Get(key) then
                return self._cache:Get(key)
        end
        local data, success = repeatPcall(self._dataStore.GetAsync, self._dataStore, key)
        if success then
                self._cache:Add(key, data)
        end
        return data
end

function Store.Set(self: Store, key: string, value: any): ()
        local _, success = repeatPcall(self._dataStore.SetAsync, self._dataStore, key, value)
        if success then
                self._cache:Add(key, value)
        end
end

function Store.Update(self: Store, key: string, updateFunction: (any) -> any): ()
        local _, success = repeatPcall(self._dataStore.UpdateAsync, self._dataStore, key, updateFunction)
        if success then
                local currVal = self._cache:Get(key)
                if currVal then
                        self._cache:Add(key, updateFunction(currVal))
                else
                        self._cache:Add(key, self:Get(key))
                end
                -- Perform update function on cached val
        end
end

local function createStore(dataStore: DataStore): Store
        return setmetatable({
                name = dataStore.Name,
                _dataStore = dataStore,
                _cache = CacheSystem:CreateTimedCache(dataStore.Name .. "TimedCache", 90)
        }, Store)
end

local function isStore(x: any): boolean
        return getmetatable(x) == Store
end

local StoreTable = {
        new = createStore,
        is = isStore
}

return StoreTable

