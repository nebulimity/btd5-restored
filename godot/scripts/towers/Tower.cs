using System;
using System.Collections.Generic;

public class Tower : Entity
{
    public TowerDef Def;
    public TowerDef BaseDef;

    public string RootId;

    public const uint LocalOwner = 0; // AS3: §3V§

    public uint Id;
    public uint Owner;

    public OccupiedSpace OccupiedSpace;

    public double SpentOn;

    public List<Tower> ChildTowers;

    public void Initialize(TowerDef def, bool updateBase = true, int seed = -1)
    {
        if (def == null)
        {
            return;
        }

        if (Rotation == 0 && def.Rotates)
        {
            Rotation = -Math.PI / 2;
        }

        Def = def;
        if (updateBase)
        {
            BaseDef = def;
        }

        OccupiedSpace = new OccupiedSpace(Main.Instance.Footprints[def.OccupiedSpace]) { X = X, Y = Y };
    }

    public void AddChildTower(Tower tower)
    {
        ChildTowers ??= new List<Tower>();
        ChildTowers.Add(tower);
        // TODO: ApplyPlatformEffects(tower); CanSell = false;
    }

    public bool IfRemovedChildTower(Tower tower)
    {
        if (ChildTowers == null) return false;

        int index = ChildTowers.IndexOf(tower);
        if (index == -1) return false;

        ChildTowers.RemoveAt(index);
        // TODO: RemovePlatformEffects(tower); and the rest of AS3's ifRemovedChildTower after the splice
        return true;
    }
}
