using System;
using System.Runtime.InteropServices;

namespace WinAPI
{
    public class User32
    {
    [DllImport("user32.dll")] public static extern int SendMessage(int hWnd,int hMsg,int wParam,int lParam);

    }

}
