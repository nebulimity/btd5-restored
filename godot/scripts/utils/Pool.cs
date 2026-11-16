using System.Collections.Generic;

public static class Pool<T> where T : class, new()
{
	private static Stack<T> _free = new Stack<T>();

	public static T Get()
	{
		if (_free.Count > 0)
		{
			return _free.Pop();
		}

		return new T();
	}

	public static void Release(T item)
	{
		if (item != null)
		{
			_free.Push(item);
		}
	}
}
