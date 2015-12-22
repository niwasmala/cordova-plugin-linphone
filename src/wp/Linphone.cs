using System;
using WPCordovaClassLib.Cordova;
using WPCordovaClassLib.Cordova.Commands;
using WPCordovaClassLib.Cordova.JSON;


namespace WPCordovaClassLib.Cordova.Commands
{
    public class Linphone : BaseCommand
    {
        public void login(string options)
        {
            string optVal = JsonHelper.Deserialize<string[]>(options)[0];

            DispatchCommandResult();
        }

        public void logout(string options)
        {
            string optVal = JsonHelper.Deserialize<string[]>(options)[0];

            DispatchCommandResult();
        }

        public void call(string options)
        {
            string optVal = JsonHelper.Deserialize<string[]>(options)[0];

            DispatchCommandResult();
        }

        public void videocall(string options)
        {
            string optVal = JsonHelper.Deserialize<string[]>(options)[0];

            DispatchCommandResult();
        }

        public void hangup(string options)
        {
            string optVal = JsonHelper.Deserialize<string[]>(options)[0];

            DispatchCommandResult();
        }

        public void toggleVideo(string options)
        {
            string optVal = JsonHelper.Deserialize<string[]>(options)[0];

            DispatchCommandResult();
        }

        public void toggleSpeaker(string options)
        {
            string optVal = JsonHelper.Deserialize<string[]>(options)[0];

            DispatchCommandResult();
        }

        public void toggleMute(string options)
        {
            string optVal = JsonHelper.Deserialize<string[]>(options)[0];

            DispatchCommandResult();
        }

        public void sendDtmf(string options)
        {
            string optVal = JsonHelper.Deserialize<string[]>(options)[0];

            DispatchCommandResult();
        }
    }
}