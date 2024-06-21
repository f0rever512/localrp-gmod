AddCSLuaFile()

function isdoor(ent)
    if not IsValid(ent) then return false end
    local class = ent:GetClass()

    if class == "func_door" or
        class == "func_door_rotating" or
        class == "prop_door_rotating" or
        class == "func_movelinear" or
        class == "prop_dynamic" then
        return true
    end
    return false
end

function unlock(ent)
    ent:Fire("unlock", "", 0)
    if isfunction(ent.UnLock) then ent:UnLock(true) end -- SCars
    if IsValid(ent.EntOwner) and ent.EntOwner ~= ent then return ent.EntOwner:keysUnLock() end -- SCars
end

function lock(ent)
    ent:Fire("lock", "", 0)
    if isfunction(ent.Lock) then ent:Lock(true) end -- SCars
    if IsValid(ent.EntOwner) and ent.EntOwner ~= ent then return ent.EntOwner:keysLock() end -- SCars
end

function fp(tbl)
    local func = tbl[1]

    return function(...)
        local fnArgs = {}
        local arg = {...}
        local tblN = table.maxn(tbl)

        for i = 2, tblN do fnArgs[i - 1] = tbl[i] end
        for i = 1, table.maxn(arg) do fnArgs[tblN + i - 1] = arg[i] end

        return func(unpack(fnArgs, 1, table.maxn(fnArgs)))
    end
end

function fnId(...)
    return ...
end

local function comp_h(a, b, ...)
    if b == nil then return a end
    b = comp_h(b, ...)
    return function(...)
        return a(b(...))
    end
end

function fc(funcs, ...)
    if type(funcs) == "table" then
        return comp_h(unpack(funcs))
    else
        return comp_h(funcs, ...)
    end
end

function fnFlip(f)
    if not f then error("not a function") end
    return function(b, a, ...)
        return f(a, b, ...)
    end
end

function fnConst(a, b)
    return a 
end