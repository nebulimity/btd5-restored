using Godot;

public partial class InGameMenu : Control
{
	private Level _level;

	[Export] private Label _cashValue;
	[Export] private Label _healthValue;

	[Export] private TextureButton _playButton;
	[Export] private TextureButton _fastForwardButton;

	[Export] private Sprite2D _blueArrowsDefault;
	[Export] private Sprite2D _blueArrowsPressed;

	[Export] private Label _roundValue;
	[Export] private Label _modeValue;
	[Export] private Label _rbeValue;

	public void Initialize(Level level)
	{
		_level = level;

		_level.RoundStarted += OnRoundStarted;
		_level.RoundEnded += OnRoundEnded;
		_level.CashChanged += OnCashChanged;
		_level.HealthChanged += OnHealthChanged;

		_cashValue.Text = _level.Cash.ToString();
		_healthValue.Text = _level.Health.ToString();
		_roundValue.Text = "-";
		_modeValue.Text = _level.Mode.ToString();
		_rbeValue.Text = "-";
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

	public override void _ExitTree()
	{
		_level.RoundStarted -= OnRoundStarted;
		_level.RoundEnded -= OnRoundEnded;
		_level.CashChanged -= OnCashChanged;
		_level.HealthChanged -= OnHealthChanged;
	}
}
