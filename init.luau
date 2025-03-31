local DataStoreService = game:GetService("DataStoreService")

local Store = require(script:WaitForChild("Store"))
local OrderedStore = require(script:WaitForChild("OrderedStore"))

export type Store = Store.Store
export type OrderedStore = OrderedStore.OrderedStore

local ServerDataSystem = {
        stores = {},
        orderedStores = {}
}

export type ServerDataSystem = typeof(ServerDataSystem)

function ServerDataSystem:GetDataStore(name: string): Store
        local store = Store.new(DataStoreService:GetDataStore(name))
        ServerDataSystem.stores[name] = store
        return store
end

function ServerDataSystem:GetOrderedDataStore(name: string): OrderedStore
        local store = OrderedStore.new(DataStoreService:GetOrderedDataStore(name))
        ServerDataSystem.orderedStores[name] = store
        return store
end

return ServerDataSystem

