local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CacheSystem = require(ReplicatedStorage.Packages.cachesystem)
type TimedCache = CacheSystem.TimedCache

local repeatPcall = require(script.Parent.RepeatPcall)

local OrderedStore = {}
OrderedStore.__index = OrderedStore

type self = {
        name: string,
        _dataStore: OrderedDataStore
}

export type OrderedStore = typeof(setmetatable({} :: self, OrderedStore))

function OrderedStore.GetSorted(self: OrderedStore, ascending: boolean, pageSize: number?, minValue: number?, maxValue: number?): DataStorePages
        return repeatPcall(self._dataStore.GetSortedAsync, self._dataStore, ascending, pageSize, minValue, maxValue)
end

function OrderedStore.Get(self: OrderedStore, key: string) 
        if self._cache:Get(key) then
                return self._cache:Get(key)
        end
        local data, success = repeatPcall(self._dataStore.GetAsync, self._dataStore, key)
        if success then
                self._cache:Add(key, data)
        end
        return data
end

function OrderedStore.Set(self: OrderedStore, key: string, value: number)
        if typeof(value) ~= "number" then
                error(`Error when attempting to set value in OrderedStore {self.name}: value to save is not a number!`, 2)
        end
        local _, success = repeatPcall(self._dataStore.SetAsync, self._dataStore, key, value)
        if success then
                self._cache:Add(key, value)
        end
end

function OrderedStore.Update(self: OrderedStore, key: string, updateFunction: (any) -> any)
        local _, success = repeatPcall(self._dataStore.UpdateAsync, self._dataStore, key, updateFunction)
        if success then
                local currVal = self._cache:Get(key)
                if currVal then
                        self._cache:Add(key, updateFunction(currVal))
                else
                        self._cache:Add(key, self:Get(key))
                end
        end
end


local function createOrderedStore(orderedDataStore: OrderedDataStore): OrderedStore
        return setmetatable({
                name = orderedDataStore.Name,
                _dataStore = orderedDataStore,
                _cache = CacheSystem:CreateTimedCache(orderedDataStore.Name .. "TimedCached", 90)
        } ,OrderedStore)
end

local function isOrderedStore(x: any): boolean
        return getmetatable(x) == OrderedStore
end

local OrderedStoreTable = {
        new = createOrderedStore,
        is = isOrderedStore
}

return OrderedStoreTable

