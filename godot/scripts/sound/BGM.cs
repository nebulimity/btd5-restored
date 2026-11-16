using Godot;

public partial class BGM : AudioStreamPlayer
{
	public static BGM Instance { get; private set; }

	private AudioStream _queued;
	private const float MaxVolume = 0.4f;

	public override void _Ready()
	{
		Instance = this;
		Bus = "Music";
	}

	public static void ToggleMute()
	{
		int index = AudioServer.GetBusIndex("Music");
		AudioServer.SetBusMute(index, !AudioServer.IsBusMute(index));
	}

	private void SetVolume(float linear)
	{
		VolumeDb = Mathf.LinearToDb(linear);
	}

	private void FadeOut()
	{
		Tween tween = CreateTween();
		tween.TweenMethod(Callable.From<float>(SetVolume), MaxVolume, 0f, 1.0);
		tween.Finished += OnFadeFinished;
	}

	private void OnFadeFinished()
	{
		StartSound(_queued);
		_queued = null;
	}

	public void PlayTrack(string path)
	{
		AudioStream stream = GD.Load<AudioStream>(path);
		PlayTrack(stream);
	}
	public void PlayTrack(AudioStream stream)
	{
		if (Playing)
		{
			if (_queued == null)
			{
				FadeOut();
			}

			_queued = stream;
			return;
		}

		StartSound(stream);
	}

	private void StartSound(AudioStream stream)
	{
		Stream = stream;
		SetVolume(MaxVolume);
		Play();
	}
}
