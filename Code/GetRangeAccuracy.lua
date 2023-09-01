function GetRangeAccuracy_Ref(props_cont, distance, unit, action)
    local effective_range_acc = 94 + props_cont.AimAccuracy
    local range_acc
    local k
    k = (100.0 - effective_range_acc)/(0.0001*props_cont.WeaponRange^3)
    range_acc = round(100.0 - 0.0001 * k * ((distance/1000.0)^3) + 0.5,1)
    return range_acc
  end
  function GetRangeAccuracy(props_cont, distance, unit, action)
    local effective_range_acc = 94 + props_cont.AimAccuracy
    local range_acc
    local k
    k = (100.0 - effective_range_acc)/(0.0001*props_cont.WeaponRange^3)
    range_acc = round(100.0 - 0.0001 * k * ((distance/1000.0)^3) + 0.5,1)
    return range_acc
  end