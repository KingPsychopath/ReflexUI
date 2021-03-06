require "base/internal/ui/reflexcore"

local trueStack = function(player)
    return math.min(
            player.armor,
            player.health * (player.armorProtection + 1)
        ) + player.health;
end

local canPickup = function(player, itemType)
    if itemType == PICKUP_TYPE_HEALTH100 then
        return player.health < 200
    elseif itemType == PICKUP_TYPE_ARMOR150 then
        return player.armorProtection < 2
            or player.armor < 200
    elseif itemType == PICKUP_TYPE_ARMOR100 then
        return player.armorProtection == 2 and player.armor < 133
            or player.armorProtection ~= 2 and player.armor < 150
    elseif itemType == PICKUP_TYPE_ARMOR50 then
        return player.armorProtection == 2 and player.armor < 66
            or player.armorProtection == 1 and player.armor < 75
            or player.armorProtection == 0 and player.armor < 100
    elseif itemType == PICKUP_TYPE_POWERUPCARNAGE then
        return player.carnageTimer == 0
    end

    return false
end


local pickup = function(player, itemType)
    if not canPickup(player, itemType) then
        return {
            armorProtection = player.armorProtection,
            armor = player.armor,
            health = player.health
        }
    elseif itemType == PICKUP_TYPE_HEALTH100 then
        return {
            armorProtection = player.armorProtection,
            armor = player.armor,
            health = math.min(200, player.health + 100)
        }
    elseif itemType == PICKUP_TYPE_ARMOR150 then
        return {
            armorProtection = 2,
            armor = math.min(200, player.armor + 150),
            health = player.health
        }
    elseif itemType == PICKUP_TYPE_ARMOR100 then
        return {
            armorProtection = 1,
            armor = math.min(150, player.armor + 100),
            health = player.health
        }
    elseif itemType == PICKUP_TYPE_ARMOR50 then
        return {
            armorProtection = 0,
            armor = math.min(100, player.armor + 50),
            health = player.health
        }
    end
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

local priorize = function(player, itemType)
    if itemType == PICKUP_TYPE_POWERUPCARNAGE then
        return 401;
    end
    return trueStack(pickup(player, itemType))
end

local receiveDamage = function(player, damage)
    local armorDamage = damage * (1 - (1/(player.armorProtection + 2)));
    local armorAbsorbs = round(math.min(
        player.armor,
        armorDamage
    ));

    return {
        armorProtection = player.armorProtection,
        armor = player.armor - armorAbsorbs,
        health = player.health - (damage - armorAbsorbs)
    }
end

return {
    trueStack = trueStack,
    canPickup = canPickup,
    pickup = pickup,
    priorize = priorize,
    receiveDamage = receiveDamage
}