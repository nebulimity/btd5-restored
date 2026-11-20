using Godot;

public partial class TowerPlaceView : Node2D
{
    [Export] private RangeCombo _rangeCombo;
    [Export] private Node2D _ghost;
    [Export] private Sprite2D _tower;
    [Export] private Sprite2D _glow;

    public void ShowView(TowerDef def)
    {
        _tower.Texture = GD.Load<Texture2D>($"res://assets/towers/{def.Display}/1.svg");
        _tower.Offset = new Vector2(-2.15f, 3.3f);
        _glow.Texture = _tower.Texture;
        _glow.Offset = _tower.Offset;

        _ghost.Rotation = def.Rotates ? -Mathf.Pi / 2 : 0;

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
