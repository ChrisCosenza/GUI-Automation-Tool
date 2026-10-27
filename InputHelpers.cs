using System;
using System.Text;
using System.Runtime.InteropServices;

// InputHelper detects keyboard presses, mouse clicks, and cursor movement.
public class InputHelper
{
    [DllImport("user32.dll")]
    private static extern short GetAsyncKeyState(int vKey);

    [DllImport("user32.dll")]
    private static extern bool GetKeyboardState(byte[] lpKeyState);

    [DllImport("user32.dll")]
    private static extern uint MapVirtualKey(uint uCode, uint uMapType);

    [DllImport("user32.dll")]
    private static extern int ToUnicode(
        uint wVirtKey,
        uint wScanCode,
        byte[] lpKeyState,
        [Out, MarshalAs(UnmanagedType.LPWStr)]
        StringBuilder pwszBuff,
        int cchBuff,
        uint wFlags);

    [DllImport("user32.dll")]
    private static extern bool GetCursorPos(out POINT lpPoint);

    [StructLayout(LayoutKind.Sequential)]
    public struct POINT
    {
        public int X;
        public int Y;
    }

    private static bool[] oldKeys = new bool[256];
    private static bool oldLeft = false;
    private static bool oldRight = false;
    private static int oldX = -1;
    private static int oldY = -1;

    public static void Reset()
    {
        int i;
        for (i = 0; i < 256; i++)
        {
            oldKeys[i] = (GetAsyncKeyState(i) & 0x8000) != 0;
        }

        oldLeft = (GetAsyncKeyState(0x01) & 0x8000) != 0;
        oldRight = (GetAsyncKeyState(0x02) & 0x8000) != 0;

        POINT p;
        if (GetCursorPos(out p))
        {
            oldX = p.X;
            oldY = p.Y;
        }
    }

    private static bool IsDown(int vk)
    {
        return (GetAsyncKeyState(vk) & 0x8000) != 0;
    }

    private static string TranslateKey(int vk)
    {
        if (vk == 0x0D) return "{ENTER}";
        if (vk == 0x09) return "{TAB}";
        if (vk == 0x08) return "{BACKSPACE}";
        if (vk == 0x1B) return "{ESC}";
        if (vk == 0x20) return " ";

        // Ignore F1-F12, including the F8/F9 recorder controls.
        if (vk >= 0x70 && vk <= 0x7B) return "";

        byte[] keyboardState = new byte[256];
        if (!GetKeyboardState(keyboardState)) return "";

        uint scanCode = MapVirtualKey((uint)vk, 0);
        StringBuilder buffer = new StringBuilder(8);

        int result = ToUnicode(
            (uint)vk,
            scanCode,
            keyboardState,
            buffer,
            buffer.Capacity,
            0);

        if (result > 0) return buffer.ToString();
        return "";
    }

    public static string GetKeyboardEvent()
    {
        int vk;
        for (vk = 1; vk < 256; vk++)
        {
            bool current = IsDown(vk);
            if (current && !oldKeys[vk])
            {
                oldKeys[vk] = true;
                string text = TranslateKey(vk);
                if (text != "") return text;
            }
            oldKeys[vk] = current;
        }
        return "";
    }

    // Returns a pipe-delimited sequence, e.g. "LEFT|" or "MOVE|120|300|".
    public static string GetMouseEvents()
    {
        StringBuilder events = new StringBuilder();

        bool left = IsDown(0x01);
        bool right = IsDown(0x02);

        if (left && !oldLeft) events.Append("LEFT|");
        if (right && !oldRight) events.Append("RIGHT|");

        oldLeft = left;
        oldRight = right;

        POINT p;
        if (GetCursorPos(out p))
        {
            if (oldX == -1 || oldY == -1)
            {
                oldX = p.X;
                oldY = p.Y;
            }
            else if (p.X != oldX || p.Y != oldY)
            {
                events.Append("MOVE|");
                events.Append(p.X);
                events.Append("|");
                events.Append(p.Y);
                events.Append("|");

                oldX = p.X;
                oldY = p.Y;
            }
        }

        return events.ToString();
    }
}

// RecorderControl provides the simple key-state check used for F8/F9.
public class RecorderControl
{
    [DllImport("user32.dll")]
    private static extern short GetAsyncKeyState(int vKey);

    public static bool IsDown(int vKey)
    {
        return (GetAsyncKeyState(vKey) & 0x8000) != 0;
    }
}
