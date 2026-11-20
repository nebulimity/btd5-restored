using System;
using System.Collections.Generic;
using Godot;

public class PlaceState : InGameMenuState
{
	public static string LastTowerPlaced;

	private TowerPickerDef _pickerDef;
	private OccupiedSpace _occupiedSpace;
	private double _rotation;
	private Level _level;

	public PlaceState(InGameMenu menu) : base(menu)
	{
		_level = Main.Instance.Level;
	}

	public override void Enter(Message message)
	{
		GameStateMessage msg = (GameStateMessage)message;

		LastTowerPlaced = msg.TowerPickerDef.Tower.Id;
		_pickerDef = msg.TowerPickerDef;

		_occupiedSpace = new OccupiedSpace(Main.Instance.Footprints[_pickerDef.Tower.OccupiedSpace]);

		_rotation = 0;
		if (_pickerDef.Tower.Rotates)
		{
			_rotation = -Math.PI / 2;
		}
		if (_pickerDef.Tower.Id == "RoadSpikes" || _pickerDef.Tower.Id == "BloonberryBush")
		{
			_rotation = Random.Shared.NextDouble() * Math.PI * 2;
		}

		Menu.TowerPlaceView.ShowView(_pickerDef.Tower, _occupiedSpace, _rotation);
		Menu.SetHandCursor(true);
	}

	public override void Exit()
	{
		Menu.TowerPlaceView.HideView();
		Menu.SetHandCursor(false);
	}

	public override State HandleMessage(Message message)
	{
		switch (((GameStateMessage)message).Type)
		{
			case GameStateMessageType.TowerPlaced:
				Machine.ChangeState(Menu.NeutralState, message);

				return null; // temp
			case GameStateMessageType.TowerPlacing:
				return Menu.PlaceState;
			case GameStateMessageType.Cancel:
				return Menu.NeutralState;
			default:
				return null;
		}
	}

	public override void HandleInput(InputEvent e)
	{
		if (e is InputEventMouseButton mouseEvent)
		{
			if (mouseEvent.ButtonIndex == MouseButton.Right && mouseEvent.Pressed)
			{
				Menu.Cancel();
			}
			else if (mouseEvent.ButtonIndex == MouseButton.Left && !mouseEvent.Pressed)
			{
				Vector2 mousePos = Menu.TowerPlaceView.GetGlobalMousePosition();
				_occupiedSpace.X = mousePos.X;
				_occupiedSpace.Y = mousePos.Y;

				if (_level.IsPlaceable(_occupiedSpace, _pickerDef.Tower.IsBoat, _pickerDef.Tower.CanPlaceOnTrack, _pickerDef.Tower.IsBoat && _pickerDef.Tower.IsLand) && (_level.CanAfford(_pickerDef.Cost, _pickerDef.Tower.Id) || _level.GetReserveCount(_pickerDef.Tower.Id) > 0))
				{
					int spentOn = _level.Purchase(_pickerDef.Cost, mousePos.X, mousePos.Y, _pickerDef.Tower.Id, null);
					uint id = _level.NextTowerId++;

					Tower tower = _level.CreateTower(Tower.LocalOwner, id, _pickerDef.Tower, mousePos.X, mousePos.Y, _rotation, new List<UpgradeDef>(), spentOn, (uint)(Random.Shared.NextDouble() * uint.MaxValue));
					Menu.PlaceUp(tower);
				}
			}
		}
		else if (e is InputEventKey keyEvent && keyEvent.Keycode == Key.Escape && keyEvent.Pressed && !keyEvent.Echo)
		{
			Menu.Cancel();
		}
	}
}
