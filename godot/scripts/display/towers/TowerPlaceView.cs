using Godot;

public partial class TowerPlaceView : Node2D
{
    [Export] private RangeCombo _rangeCombo;
    [Export] private Node2D _ghost;
    [Export] private Sprite2D _tower;
    [Export] private Sprite2D _glow;

    private TowerDef _def;
    private OccupiedSpace _occupiedSpace;

    public void ShowView(TowerDef def, OccupiedSpace space, double rotation)
    {
        _def = def;
        _occupiedSpace = space;

        _tower.Texture = GD.Load<Texture2D>($"res://assets/towers/{def.Display}/1.svg");
        _glow.Texture = _tower.Texture;
        _glow.Offset = _tower.Offset;

        _ghost.Rotation = (float)rotation;

        _rangeCombo.SetRange(def.RangeOfVisibility, true);

        Visible = true;
        _ghost.Visible = true;
        UpdatePosition();
    }

    public void HideView()
    {
        Visible = false;
        _ghost.Visible = false;
    }

    public void UpdatePosition()
    {
        Vector2 mousePos = GetGlobalMousePosition();
        GlobalPosition = mousePos;
        _ghost.Position = mousePos;

        _occupiedSpace.X = mousePos.X;
        _occupiedSpace.Y = mousePos.Y;
        bool isValid = Main.Instance.Level.IsPlaceable(_occupiedSpace, _def.IsBoat, _def.CanPlaceOnTrack, _def.IsBoat && _def.IsLand);
        _rangeCombo.SetRange(_def.RangeOfVisibility, isValid);
    }

    public override void _Process(double delta)
    {
        if (!Visible)
        {
            return;
        }

        UpdatePosition();
    }
}
