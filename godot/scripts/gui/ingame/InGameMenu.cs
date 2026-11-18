using Godot;

public partial class InGameMenu : Control
{
	private Level _level;

	private Machine _stateMachine;
	public NeutralState NeutralState;
	public PlaceState PlaceState;
	public TowerSelectedState TowerSelectedState;
	public TowerNotSelectedState TowerNotSelectedState;

	[Export] private Label _cashValue;
	[Export] private Label _healthValue;

	[Export] private TextureButton _playButton;
	[Export] private TextureButton _fastForwardButton;

	[Export] private Sprite2D _blueArrowsDefault;
	[Export] private Sprite2D _blueArrowsPressed;

	[Export] private Label _roundValue;
	[Export] private Label _modeValue;
	[Export] private Label _rbeValue;

	[Export] private TextureButton _dartTower;
	[Export] private TextureButton _tackTower;
	[Export] private TextureButton _sniperMonkey;
	[Export] private TextureButton _boomerangTower;
	[Export] private TextureButton _ninjaMonkey;
	[Export] private TextureButton _bombTower;
	[Export] private TextureButton _iceTower;
	[Export] private TextureButton _glueTower;
	[Export] private TextureButton _buccaneerTower;
	[Export] private TextureButton _aceTower;
	[Export] private TextureButton _superTower;
	[Export] private TextureButton _wizardTower;
	[Export] private TextureButton _villageTower;
	[Export] private TextureButton _farmTower;
	[Export] private TextureButton _mortarTower;
	[Export] private TextureButton _dartlingTower;
	[Export] private TextureButton _spikeFactory;
	[Export] private TextureButton _monkeySub;

	public void Initialize(Level level)
	{
		_level = level;
		_stateMachine = new Machine();

		PlaceState = new PlaceState(this);
		TowerSelectedState = new TowerSelectedState(this);
		TowerNotSelectedState = new TowerNotSelectedState(this);
		NeutralState = new NeutralState(this);
		_stateMachine.ChangeState(NeutralState, null);

		_level.RoundStarted += OnRoundStarted;
		_level.RoundEnded += OnRoundEnded;
		_level.CashChanged += OnCashChanged;
		_level.HealthChanged += OnHealthChanged;

		_cashValue.Text = _level.Cash.ToString();
		_healthValue.Text = _level.Health.ToString();
		_roundValue.Text = "-";
		_modeValue.Text = _level.Mode.ToString();
		_rbeValue.Text = "-";

		TowerPickerDef topMenu = new TowerPickerDef
		{
			
		};
	}

	private void OnRoundStarted()
	{
		_playButton.Visible = false;
		_fastForwardButton.Visible = true;
		_blueArrowsDefault.Visible = true;
		_blueArrowsPressed.Visible = false;

		if (_level.WaveIndex + 1 <= _level.EndRound)
		{
			_roundValue.Text = (_level.WaveIndex + 1).ToString() + " of " + _level.EndRound;
		}

		_rbeValue.Text = _level.WaveSet.CurrentRBE.ToString();
	}

	private void OnRoundEnded()
	{
		_playButton.Visible = true;
		_fastForwardButton.Visible = false;

		_level.UpdateMultiplier = 1;
	}

	private void OnCashChanged()
	{
		_cashValue.Text = ((int)_level.Cash).ToString();
	}

	private void OnHealthChanged()
	{
		_healthValue.Text = _level.Health.ToString();
	}

	private void OnPlayButtonPressed()
	{
		_level.StartRound();
	}

	private void OnFastForwardButtonPressed()
	{
		bool isFastForward = _level.UpdateMultiplier != 3;
		_level.UpdateMultiplier = isFastForward ? 3 : 1;

		_blueArrowsDefault.Visible = !isFastForward;
		_blueArrowsPressed.Visible = isFastForward;
	}

	public void Cancel()
	{
		_stateMachine.Send(new GameStateMessage(GameStateMessageType.Cancel));
	}

	public void Place(TowerPickerDef towerPickerDef)
	{
		Cancel();
		GameStateMessage gameStateMessage = new GameStateMessage(GameStateMessageType.TowerPlacing) { TowerPickerDef = towerPickerDef };
		_stateMachine.Send(gameStateMessage);
	}

	public void PlaceUp(Tower tower)
	{
		GameStateMessage gameStateMessage = new GameStateMessage(GameStateMessageType.TowerPlaced) { Tower = tower };
		_stateMachine.Send(gameStateMessage);
	}

	public override void _ExitTree()
	{
		_level.RoundStarted -= OnRoundStarted;
		_level.RoundEnded -= OnRoundEnded;
		_level.CashChanged -= OnCashChanged;
		_level.HealthChanged -= OnHealthChanged;
	}
}
