﻿// Console application adapted from NatNet SDK SampleClientML.cs

/* 
Copyright © 2016 NaturalPoint Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Sockets;
using System.Threading.Tasks;
using System.Timers;
using NatNetML;

namespace CalibrationConsole
{
    class CalibrationClient
    {
        private HoloDataClient holoDataClient_ = null;
        private NatNetClient natNetClient_ = null;
        private MLApp.MLApp matlab_ = null;

        // Keep spaces
        private bool requireSpaces_ = false;

        // Event log
        private string eventLogFilePrefix_ = "event-log";
        private string eventLogFile_ = "";

        // Marker and gaze trace
        private string otLogFilePrefix_ = "ot-log";
        private string otLogFile_ = "";

        // Trace in kb frame
        private string traceLogFilePrefix_ = "kbtrace-log";
        private string traceLogFile_ = "";

        private System.Timers.Timer timer_ = null;
        private System.Timers.Timer timer1_ = null;
        private DateTime logStartTime_;
        private static int index = 1;
        private static List<List<double>> HLdata = new List<List<double>>();
        private static List<List<double>> OPdata = new List<List<double>>();
        private static List<string> phraseList_ = new List<string>();
        private static int idxHl_ = 0;



        //private bool checkend = true;
        //public string messageString = "";


        // Constructor
        CalibrationClient(HoloDataClient holoDataClient, NatNetClient natNetClient, bool requireSpaces)
        {
            requireSpaces_ = requireSpaces;
            

            phraseList_ = ImportPhraseList("phrase-list.txt");

            // Create the MATLAB instance 
            matlab_ = new MLApp.MLApp();
            // Change to the directory where the function is located 
            string startupPath = Environment.CurrentDirectory;            
            string pathCmd = string.Format("cd {0}\\..\\..", startupPath);
            matlab_.Execute(pathCmd);

            holoDataClient_ = holoDataClient;
            natNetClient_ = natNetClient;

            // Start fetch loop for HL pose data (every 2s)
            holoDataClient_.StartFetchLoop(2000);
            holoDataClient_.OnPoseUpdate = PoseDataReceived;
        }

        private static string getInput(string request)
        {
            //bool inputReceived = true;
            Console.WriteLine("====================");
            Console.WriteLine(request);

            string reply = Console.ReadLine();
            int no = Convert.ToInt32(reply);
            //if (reply == "exit")
            //{
            //    inputReceived = false;
            //}
            string message = phraseList_[no];

            return message;
        }



        public void nnStartFetchLoop(int interval , string messageString)
        {
            // Create a timer and set a two second interval.
            timer_ = new System.Timers.Timer();
            timer_.Interval = interval;

            // Hook up the Elapsed event for the timer. 
            timer_.Elapsed += (source, e) => ProcessAllData(source, e, messageString);

            // Start the timer
            //timer_.Enabled = true;
            timer_.Start();
        }

        public void GetLatestHLdata()
        {
            idxHl_ = HLdata.Count() - 1;

            Console.WriteLine("Index HL_" + HLdata.Count());
        }

        private List<string> ImportPhraseList(string path)
        {
            string test = File.ReadAllText(path);
            string[] lineSep = new string[] { "\r\n", "\n" };
            string[] lines = test.Split(lineSep, StringSplitOptions.RemoveEmptyEntries);

            List<string> phrases = new List<string>();

            // Loop over lines
            foreach (string l in lines)
            {
                // Split on tab
                string[] lSplit = l.Split('\t');
                if (lSplit.Length == 2)
                {
                    phrases.Add(lSplit[1]);
                }
            }

            return phrases;
        }

        private void SendhHoloLensData(string messageString)
        {
            try
            {
                holoDataClient_.SendMessage( "kb_add_word\t"+messageString);

            }
            catch (SystemException exception)
            {
                Console.WriteLine("Exception: {0}", exception);
            }
        }

        private void clearHoloLensData()
        {
            try
            {
                holoDataClient_.SendMessage("kb_clear");

            }
            catch (SystemException exception)
            {
                Console.WriteLine("Exception: {0}", exception);
            }
        }

   
        // Handle new pose update event
        private void ProcessAllData(Object source, System.Timers.ElapsedEventArgs e, string messageString)
        {



            NatNetClient.NatNetPoseData nnPoseData = natNetClient_.FetchFrameData();

            index = handledata( nnPoseData, index, messageString);

            var words = messageString.Split(null);
            int wordcount = words.Length;

            int length = messageString.Length - wordcount + 1;

            // Special case if require spaces, don't subtract wordcount (i.e. n spaces)
            if (requireSpaces_)
            {
                length = messageString.Length;
            }            
            
            if (index > length + 2)
            {
                // Update done key
                holoDataClient_.UpdateDoneKeyState(2);

                Console.WriteLine("Completed: " + messageString);
                Console.WriteLine("Char Count: "+length);
                Console.WriteLine("===============================\n\n");

                // Increment index to update the KB pose based on latest data
                GetLatestHLdata();

                //clearHoloLensData();
                SendhHoloLensData(messageString);
                timer_.Enabled = false;
                timer_.Dispose();
                //checkend = false;
                
                index = 1;
                //Console.WriteLine("Enter new word");                
                // Send message to server
                string messageRequest = "Enter new word";

                
                string newWord = getInput(messageRequest);                
                NewPhrase(newWord);
            }

            LogData(nnPoseData);
        }

        private void LogData(NatNetClient.NatNetPoseData nnPoseData)
        {
            string log = "";
            log += string.Format("{0:F6},{1:F6},{2:F6},", nnPoseData.rbPos.X, nnPoseData.rbPos.Y, nnPoseData.rbPos.Z);
            log += string.Format("{0:F8},{1:F8},{2:F8},{3:F8},", nnPoseData.rbRot.W, nnPoseData.rbRot.X, nnPoseData.rbRot.Y, nnPoseData.rbRot.Z);
            log += string.Format("{0:F6},{1:F6},{2:F6},", nnPoseData.mPos.X, nnPoseData.mPos.Y, nnPoseData.mPos.Z);

            // Add timestamp            
            string timestamp = Math.Round((System.DateTime.Now - logStartTime_).TotalMilliseconds).ToString();
            log += string.Format("{0}", timestamp);

            //WriteToLogMRB(log);
            WriteToFile(otLogFile_, log);
        }

        private void LogKBData(double[] newmarkerpos1)
        {
            string log = "";
            log += string.Format("{0:F6},{1:F6},{2:F6},", (double)newmarkerpos1[0], (double)newmarkerpos1[1], (double)newmarkerpos1[2]);
    

            // Add timestamp            
            string timestamp = Math.Round((System.DateTime.Now - logStartTime_).TotalMilliseconds).ToString();
            log += string.Format("{0}", timestamp);

            //WriteToLogKB(log);
            WriteToFile(traceLogFile_, log);
        }

        private int handledata(NatNetClient.NatNetPoseData nnPoseData, int index, string targetWord)
        {
            //int idxhl = 0;
   
            if (HLdata.Count == 0)
            {
                // Console.Write('o');
                return 1;
            }

            double[] rbpos = new double[3] { (double)OPdata[idxHl_][0], (double)OPdata[idxHl_][1], (double)OPdata[idxHl_][2] };
            double[] rbquat = new double[4] { (double)OPdata[idxHl_][3], (double)OPdata[idxHl_][4], (double)OPdata[idxHl_][5], (double)OPdata[idxHl_][6] };
            double[] kbP = new double[3] { (double)HLdata[idxHl_][0], (double)HLdata[idxHl_][1], (double)HLdata[idxHl_][2] };
            double[] kbQ = new double[4] { (double)HLdata[idxHl_][3], (double)HLdata[idxHl_][4], (double)HLdata[idxHl_][5], (double)HLdata[idxHl_][6] };
            double[] hlPs = new double[3] { (double)HLdata[idxHl_][7], (double)HLdata[idxHl_][8], (double)HLdata[idxHl_][9] };
            double[] hlQs = new double[4] { (double)HLdata[idxHl_][10], (double)HLdata[idxHl_][11], (double)HLdata[idxHl_][12], (double)HLdata[idxHl_][13] };

            double[] mkpos = new double[3] { nnPoseData.mPos.X, nnPoseData.mPos.Y, nnPoseData.mPos.Z };

            object newmarkerpos = null;

            matlab_.Feval("trans", 3, out newmarkerpos, mkpos, rbpos, rbquat, kbP, kbQ, hlPs, hlQs);
            object[] res = newmarkerpos as object[];


            double xpos = Convert.ToDouble(res[0]);
            double ypos = Convert.ToDouble(res[1]);
            double zpos = Convert.ToDouble(res[2]);


            double[] newmarkerpos1 = new double[3] { xpos, ypos, zpos };
            LogKBData(newmarkerpos1);

            object result1 = null;
            // Console.WriteLine('p');
            //Console.WriteLine(index);
            //matlab_.Feval("recognitioncopy", 2, out result1, newmarkerpos1, index, targetWord); 
            string testPhrase = targetWord;
            if (requireSpaces_)
            {
                testPhrase= testPhrase.Replace(' ', '_');
            }
            //Console.WriteLine(testPhrase);
            //Console.WriteLine(requireSpaces_);
            matlab_.Feval("recognitioncopy", 2, out result1, newmarkerpos1, index, testPhrase.ToLower());



            object[] res2 = result1 as object[];
            //Console.WriteLine('p');
            //Console.WriteLine(res2[0]);
            //Console.WriteLine('p');
                       
            //Console.WriteLine('p');
            

            int preIndex = index;
            index = Convert.ToInt32(res2[0]);
            
            if (index == preIndex + 1)
            {
                Console.WriteLine("result: " + res2[1] + "\t[" + preIndex + "->" + index +"]");

                // holoDataClient_.AddCharacter((string)res2[1]);
                
                if (preIndex == 1)
                {
                    holoDataClient_.UpdateDoneKeyState(1);
                }
            }



            // Console.WriteLine(index);
            return index;

        }



        // Handle new pose update event
        private void PoseDataReceived(HoloDataClient.HoloPose poseData)
        {
            // Fetch nnPose to be approx synchronised with HL pose
            NatNetClient.NatNetPoseData nnPoseData = natNetClient_.FetchFrameData();

            // Check that log file name has been initialized
            if (eventLogFile_ != "")
            {
                // Assemble log line
                string log = "";
                log += string.Format("{0:F6},{1:F6},{2:F6},", poseData.camPos.X, poseData.camPos.Y, poseData.camPos.Z);
                log += string.Format("{0:F8},{1:F8},{2:F8},{3:F8},", poseData.camRot.W, poseData.camRot.X, poseData.camRot.Y, poseData.camRot.Z);
                log += string.Format("{0:F6},{1:F6},{2:F6},", poseData.kbPos.X, poseData.kbPos.Y, poseData.kbPos.Z);
                log += string.Format("{0:F8},{1:F8},{2:F8},{3:F8},", poseData.kbRot.W, poseData.kbRot.X, poseData.kbRot.Y, poseData.kbRot.Z);
                log += string.Format("{0:F6},{1:F6},{2:F6},", nnPoseData.rbPos.X, nnPoseData.rbPos.Y, nnPoseData.rbPos.Z);
                log += string.Format("{0:F8},{1:F8},{2:F8},{3:F8},", nnPoseData.rbRot.W, nnPoseData.rbRot.X, nnPoseData.rbRot.Y, nnPoseData.rbRot.Z);

                // Add timestamp            
                string timestamp = Math.Round((System.DateTime.Now - logStartTime_).TotalMilliseconds).ToString();

                log += string.Format("{0}", timestamp);

                WriteToFile(eventLogFile_, log);
            }

            // Append data to HL and OP data lists
            List<double> hldata = new List<double>() { poseData.kbPos.X, poseData.kbPos.Y, poseData.kbPos.Z, poseData.kbRot.W, poseData.kbRot.X, poseData.kbRot.Y, poseData.kbRot.Z, poseData.camPos.X, poseData.camPos.Y, poseData.camPos.Z, poseData.camRot.W, poseData.camRot.X, poseData.camRot.Y, poseData.camRot.Z };
            List<double> opdata = new List<double>() { nnPoseData.rbPos.X, nnPoseData.rbPos.Y, nnPoseData.rbPos.Z, nnPoseData.rbRot.W, nnPoseData.rbRot.X, nnPoseData.rbRot.Y, nnPoseData.rbRot.Z };
            HLdata.Add(hldata);
            OPdata.Add(opdata);
        }
           
        // Write line to output file
        public async Task WriteToFile(string file, string line)
        {
            using (StreamWriter outputFile = new StreamWriter(file, true))
            {
                await outputFile.WriteLineAsync(line);
            }
        }

        public void NewPhrase(string stimulus)
        {
            Console.WriteLine("Stimulus: " + stimulus);

            // Send the stimulus to the HoloServer
            holoDataClient_.SendStimulus(stimulus);
            holoDataClient_.UpdateDoneKeyState(0);

            //Console.Write(messageString1);
            logStartTime_ = System.DateTime.Now;

            string phrase = stimulus.ToLower();
            phrase = phrase.Replace(' ', '_');
            string logSuffix = "_" + phrase + logStartTime_.ToString("_yyMMdd_hhmmss") + ".csv";
            eventLogFile_ = eventLogFilePrefix_ + logSuffix;

            // Write header to event log file
            WriteToFile(eventLogFile_, "# hl_pos_x,hl_pos_y,hl_pos_z,hl_rot_w,hl_rot_x,hl_rot_y,hl_rot_z, kb_pos_x,kb_pos_y,kb_pos_z,kb_rot_w,kb_rot_x,kb_rot_y,kb_rot_z,rb_pos_x,rb_pos_y,rb_pos_z,rb_rot_w,rb_rot_x,rb_rot_y,rb_rot_z,timestamp");

            otLogFile_ = otLogFilePrefix_ + logSuffix;
            traceLogFile_ = traceLogFilePrefix_ + logSuffix;


            nnStartFetchLoop(10, stimulus);
            //Console.Write(messageString1);
            return;


        }
        


        // Main function
        static void Main(string[] args)
        {

            string messageRequest = "\nEnter message then press Enter. Type 'exit' to quit.";
            //string messageString = "";


            // Initialize HoloDataClient
            HoloDataClient holoClient = new HoloDataClient();
            holoClient.ConnectToServer("192.168.1.101", 11001);
            //holoClient.ConnectToServer("127.0.0.1", 11001);

            // Initialize NatNetClient
            NatNetClient nnClient = new NatNetClient();
            nnClient.Connect();

            // Don't require spaces
            //CalibrationClient calClient = new CalibrationClient(holoClient, nnClient);

            // Require spaces
            CalibrationClient calClient = new CalibrationClient(holoClient, nnClient, true);

            Console.WriteLine("======================== STREAMING DATA (PRESS ESC TO EXIT) =====================\n");

            //if (!getInput(messageRequest, out messageString))
            //{
            //    break;
            //}

            // Send message to server
            string word = getInput(messageRequest);
            calClient.NewPhrase(word);

            // Infinite loop
            while (true)
            {
                // Continuously listening for Frame data
                // Enter ESC to exit
            }

            // Disconnect clients
            holoClient.Disconnect();
            nnClient.Disconnect();
        }

    }
}
