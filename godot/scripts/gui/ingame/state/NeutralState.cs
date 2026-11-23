using System;
using Godot;

public class NeutralState : InGameMenuState
{
	private Tower _minTower;

	public Machine ChildState = new Machine();
	private Level _level;

	public NeutralState(InGameMenu menu) : base(menu)
	{
		_level = Main.Instance.Level;
		ChildState.ChangeState(menu.TowerNotSelectedState, null);
	}

	public override void Enter(Message message)
	{

	}

	public override void Exit()
	{
		if (_minTower != null)
		{
			Menu.TowerHighlight.SetTower(null);
		}
	}

	public override State HandleMessage(Message message)
	{
		if (((GameStateMessage)message).Type == GameStateMessageType.TowerPlacing)
		{
			return Menu.PlaceState;
		}

		ChildState.Send(message);
		return null;
	}

	public override void HandleInput(InputEvent e)
	{
		if (e is InputEventMouseButton mouseEvent && mouseEvent.ButtonIndex == MouseButton.Left && mouseEvent.Pressed)
		{
			if (_minTower != null)
			{
				ChildState.Send(new GameStateMessage(GameStateMessageType.TowerSelected) { Tower = _minTower });
			}
			else
			{
				ChildState.Send(new GameStateMessage(GameStateMessageType.TowerNotSelected));
			}
		}
		else if (e is InputEventMouseMotion motion)
		{
			if (motion.Relative == Vector2.Zero)
			{
				return;
			}

			Vector2 mousePos = Menu.TowerPlaceView.GetGlobalMousePosition();
			double mouseX = mousePos.X;
			double mouseY = mousePos.Y;
			double minDistSq = 9999999;

			_minTower = null;

			foreach (var tower in _level.AllTowers)
			{
				if (Menu.TowerSelectedState.Tower == tower && tower.Def.IsPlatform)
				{
					continue;
				}
				// if (tower.Owner == Tower.AllyOwner)
				// {
				// 	continue;
				// }

				double dx = mouseX - tower.X;
				double dy = mouseY - tower.Y;
				double distSq = dx * dx + dy * dy;

				if (distSq < minDistSq)
				{
					minDistSq = distSq;
					_minTower = tower;
				}
			}

			if (minDistSq < 2500)
			{
				Menu.TowerHighlight.SetTower(_minTower);
				Menu.SetHandCursor(true);
			}
			else
			{
				_minTower = null;
				Menu.TowerHighlight.SetTower(null);
				Menu.SetHandCursor(false);
			}
		}
	}
}
