using UnityEngine;

public class EnemyController : MonoBehaviour
{
    public class Dmg
    {
        public Dmg(int? val) { amount = val; } 

        public Dmg(double? val)
        {
            if (val.HasValue)
                amount = (int)System.Math.Round(val.Value);
            else amount = null;
        }

        public int? amount; //null if miss, neg if healing, pos if hurting;
    }

    internal Sprite textBubbleSprite;

    internal Vector2 textBubblePos;
    protected int maxHP;
    protected int currentHP;

    protected UIController ui;

    public virtual string Name { get; set; }
    public virtual string[] ActCommands { get; set; }
    public virtual string[] Comments { get; set; }
    public virtual string[] Dialogue { get; set; }
    public virtual string CheckData { get; set; }
    public virtual int HP { get; set; }
    public virtual int Attack { get; set; }
    public virtual int Defense { get; set; }
    public virtual int XP { get; set; }
    public virtual int Gold { get; set; }
    public virtual bool CanSpare { get; set; }
    public virtual bool CanCheck { get; set; }
    public virtual string DialogBubble { get; protected set; }

    public Vector2 DialogBubblePosition
    {
        get
        {
            Sprite diagBubbleSpr = SpriteRegistry.Get(DialogBubble);
            RectTransform t = GetComponent<RectTransform>();
            if (diagBubbleSpr.name.StartsWith("right"))
                textBubblePos = new Vector2(t.rect.width + 5, (-t.rect.height + diagBubbleSpr.rect.height) / 2);
            else if (diagBubbleSpr.name.StartsWith("left"))
                textBubblePos = new Vector2(-diagBubbleSpr.rect.width - 5, (-t.rect.height + diagBubbleSpr.rect.height) / 2);
            else if (diagBubbleSpr.name.StartsWith("top"))
                textBubblePos = new Vector2((t.rect.width - diagBubbleSpr.rect.width) / 2, diagBubbleSpr.rect.height + 5);
            else if (diagBubbleSpr.name.StartsWith("bottom"))
                textBubblePos = new Vector2((t.rect.width - diagBubbleSpr.rect.width) / 2, -t.rect.height - 5);
            else
                textBubblePos = new Vector2(t.rect.width + 5, (t.rect.height - diagBubbleSpr.rect.height) / 2); // rightside default
            return textBubblePos;
        }
    }

    public void Handle(string command)
    {
        string cmd = command.ToUpper().Trim();
        if (CanCheck && cmd.Equals("CHECK"))
            HandleCheck();
        else
            HandleCustomCommand(cmd);
    }

    //Function fires before damage is calculated. Including this function in your LUA causes 
    //rateToCenter = -1: exact left side hit, multiplier should be equal to 1 (0?)
    //rateToCenter = 0 : exact center hit, since this relies on perfect game timing, never assume this. mult gets bonus from 2 to 2.2
    //rateToCenter = 1 : exact right side hit, multiplier should be equal to 1
    //rateToCenter = N/A, +inf or -inf : missed
    //for return value, if there is no function, call void in a function to indicate regular damage calcs, nil to indicate misses, and 0 to indicate no damage.
    //NOTE: due to the current nature of damage, healing damage also hurts, zero damage is a miss
    public virtual Dmg HandlePreAttack(float rateToCenter)
    {
        ui.ActionDialogResult(new RegularMessage("Your pre-attack handler\ris missing."), UIController.UIState.ENEMYDIALOGUE);
        return null;
    }

    // hitstatus -1: you didn't press anything while attacking
    // hitstatus  0: you dealt no damage
    // hitstatus  1: you dealt any amount of damage
    public virtual void HandleAttack(int hitStatus)
    {
        ui.ActionDialogResult(new RegularMessage("Your attack handler\ris missing."), UIController.UIState.ENEMYDIALOGUE);
    }

    public virtual void AttackStarting()
    {
    }

    protected virtual void HandleCustomCommand(string command)
    {
        ui.ActionDialogResult(new RegularMessage("Command handler missing.\nGood job."), UIController.UIState.DEFENDING);
    }

    public virtual void HandleCheck()
    {
        ui.ActionDialogResult(new RegularMessage(Name.ToUpper() + " " + Attack + " ATK " + Defense + " DEF\n" + CheckData), UIController.UIState.ENEMYDIALOGUE);
    }

    public int getMaxHP()
    {
        return maxHP;
    }

    public void doDamage(int damage)
    {
        int newHP = HP - damage;
        if (newHP < 0)
            newHP = 0;
        HP = newHP;
    }

    public virtual string[] GetDefenseDialog()
    {
        string[] randoms = new string[] {
            "Check\nit out.",
            "That's\nsome\nsolid\ntext.",
            "More\ntext,\nplease.",
            "We're\ngetting\ncloser.",
            "You\nguys\nSUCK\nat this."
        };
        return new string[] { randoms[Random.Range(0, randoms.Length)] };
    }
}