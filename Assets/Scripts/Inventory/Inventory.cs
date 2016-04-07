using System.Collections.Generic;

/// <summary>
/// Static placeholder inventory class for the player. Will probably get moved to something else that makes sense, like the player.
/// </summary>
public static class Inventory
{
	public const int MAX_ITEMS = 8;
    public static List<UnderItem> container = new List<UnderItem>(
        new UnderItem[]{
            new UnderItem(),
            new UnderItem(),
            new UnderItem(),
            new UnderItem(),
            new UnderItem(),
            new UnderItem(),
            new UnderItem()
        }
    );

	public static bool TryAdd(UnderItem item)
	{
		if (container.Count >= MAX_ITEMS)
		{
			return false;
		}
		if (container == null || item == null) 
		{ 
			return false;
		}
		container.Add(item);
		return true;
	}

	public static void RemoveItem(string id)
	{
		var item = container.Find((u) => u.ID == id);
		if (item != null)
		{
			container.Remove(item);
		}
	}
}