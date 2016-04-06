using UnityEngine;
using System.Collections;

public class KeyboardInput : UndertaleInput {

    public override UndertaleInput.ButtonState Confirm
    {
        get { return stateFor("Z"); }
    }

    public override UndertaleInput.ButtonState Cancel
    {
        get { return stateFor("X"); }
    }

    public override UndertaleInput.ButtonState Menu
    {
        get { return stateFor("C"); }
    }

    public override UndertaleInput.ButtonState Up
    {
        get { return stateFor("Up"); }
    }

    public override UndertaleInput.ButtonState Down
    {
        get { return stateFor("Down"); }
    }

    public override UndertaleInput.ButtonState Left
    {
        get { return stateFor("Left"); }
    }

    public override UndertaleInput.ButtonState Right
    {
        get { return stateFor("Right"); }
    }

	private ButtonState stateFor(string input)
	{
		if(Input.GetButtonDown(input))
		{
			return ButtonState.PRESSED;
		}
		else if (Input.GetButtonUp(input))
        {
            return ButtonState.RELEASED;
        }
        else if (Input.GetButton(input))
        {
            return ButtonState.HELD;
        }
        else
        {
            return ButtonState.NONE;
        }
	}

    private ButtonState stateFor(KeyCode c)
    {
        if (Input.GetKeyDown(c))
        {
            return ButtonState.PRESSED;
        }
        else if (Input.GetKeyUp(c))
        {
            return ButtonState.RELEASED;
        }
        else if (Input.GetKey(c))
        {
            return ButtonState.HELD;
        }
        else
        {
            return ButtonState.NONE;
        }
    }

    private ButtonState stateFor(KeyCode a, KeyCode b)
    {
        ButtonState aState = stateFor(a);
        if (aState != ButtonState.NONE)
        {
            return aState;
        }
        else
        {
            return stateFor(b);
        }
    }

    private ButtonState stateFor(params KeyCode[] keys)
    {
        foreach(KeyCode key in keys){
            ButtonState state = stateFor(key);
            if (state != ButtonState.NONE)
            {
                return state;
            }
        }
        return ButtonState.NONE;
    }
}
