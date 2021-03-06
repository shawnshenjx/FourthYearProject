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
using System.Net.Sockets;
using System.Timers;
using NatNetML;

namespace CalibrationConsole
{
    class CalibrationClient
    {
        private HoloDataClient holoDataClient_ = null;
        private NatNetClient natNetClient_ = null;
        private MLApp.MLApp matlab_ = null;
        // private string outputFile_ = "calibration_log";
        private string mrbOutputFile_ = "";
        private List<string> mrbLogList_ = null;

        private string kbTraceOutputFile_ = "";
        private List<string> mPosKbLogList_ = null;



        private System.Timers.Timer timer_ = null;
        private DateTime logStartTime_;
        private static int index = 1;
        private static List<List<double>> HLdata = new List<List<double>>();
        private static List<List<double>> OPdata = new List<List<double>>();
        //private bool checkend = true;
        //public string messageString = "";


        // Constructor
        CalibrationClient(HoloDataClient holoDataClient, NatNetClient natNetClient)
        {
            // Create the MATLAB instance 
            InitializeMatlab();

            holoDataClient_ = holoDataClient;
            natNetClient_ = natNetClient;

            mrbLogList_ = new List<string>();
            mPosKbLogList_ = new List<string>();
        }

        private void InitializeMatlab()
        {
            // Create the MATLAB instance 
            matlab_ = new MLApp.MLApp();
            // Change to the directory where the function is located 
            string startupPath = Environment.CurrentDirectory;
            string pathCmd = string.Format("cd {0}\\..\\..", startupPath);
            matlab_.Execute(pathCmd);
        }

        private static string getInput(string request)
        {
            //bool inputReceived = true;

            Console.WriteLine(request);
            string reply = Console.ReadLine();
            //if (reply == "exit")
            //{
            //    inputReceived = false;
            //}

            return reply;
        }



        public void nnStartFetchLoop(int interval , string messageString)
        {
            if (timer_ != null)
            {
                timer_.Stop();
            }

            // Create a timer and set a two second interval.
            timer_ = new System.Timers.Timer();
            timer_.Interval = interval;

            // Hook up the Elapsed event for the timer. 
            timer_.Elapsed += (source, e) => ProcessAllData(source, e, messageString);

            // Start the timer
            //timer_.Enabled = true;
            timer_.Start();
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


            if (index > messageString.Length)
            {
                Console.WriteLine("Completed: " + messageString);
                Console.WriteLine("Logging to file");
                WriteLogDataFile(mrbOutputFile_, mrbLogList_);
                WriteLogDataFile(kbTraceOutputFile_, mPosKbLogList_);
                Console.WriteLine("Logging complete");
                // Reset the log buffers
                mrbLogList_ = new List<string>();
                mPosKbLogList_ = new List<string>();
                Console.WriteLine("===============================\n\n");
                SendhHoloLensData(messageString);
                timer_.Enabled = false;
                timer_.Dispose();
                //checkend = false;

                index = 1;
                //Console.WriteLine("Enter new word");                
                // Send message to server
                string messageRequest = "Enter new word";

                clearHoloLensData();
                string newWord = getInput(messageRequest);
                InterpretMessage(newWord);
            }

            LogData(nnPoseData);
           

        }

        private void LogData(NatNetClient.NatNetPoseData nnPoseData)
        {
            string log = "";
            log += string.Format("{0:F6},{1:F6},{2:F6},", nnPoseData.rbPos.X, nnPoseData.rbPos.Y, nnPoseData.rbPos.Z);
            log += string.Format("{0:F8},{1:F8},{2:F8},{3:F8},", nnPoseData.rbRot.W, nnPoseData.rbRot.X, nnPoseData.rbRot.Y, nnPoseData.rbRot.Z);
            log += string.Format("{0:F8},{1:F8},{2:F8},{3:F8},", nnPoseData.rbRot.W, nnPoseData.rbRot.X, nnPoseData.rbRot.Y, nnPoseData.rbRot.Z);


            // Add timestamp            
            string timestamp = Math.Round((System.DateTime.Now - logStartTime_).TotalMilliseconds).ToString();
            log += string.Format("{0}", timestamp);

            WriteToLogMRB(log);
        }

        private void LogKBData(double[] newmarkerpos1)
        {
            string log = "";
            log += string.Format("{0:F6},{1:F6},{2:F6},", (double)newmarkerpos1[0], (double)newmarkerpos1[1], (double)newmarkerpos1[2]);
    

            // Add timestamp            
            string timestamp = Math.Round((System.DateTime.Now - logStartTime_).TotalMilliseconds).ToString();
            log += string.Format("{0}", timestamp);

            WriteToLogKB(log);
        }

        private int handledata(NatNetClient.NatNetPoseData nnPoseData, int index, string targetWord)
        {
            int idxHl = 0;
            if (HLdata.Count == 0)
            {
                // Console.Write('o');
                return 1;
            }

            double[] rbpos = new double[3] { (double)OPdata[idxHl][0], (double)OPdata[idxHl][1], (double)OPdata[idxHl][2] };
            double[] rbquat = new double[4] { (double)OPdata[idxHl][3], (double)OPdata[idxHl][4], (double)OPdata[idxHl][5], (double)OPdata[idxHl][6] };
            double[] kbP = new double[3] { (double)HLdata[idxHl][0], (double)HLdata[idxHl][1], (double)HLdata[idxHl][2] };
            double[] kbQ = new double[4] { (double)HLdata[idxHl][3], (double)HLdata[idxHl][4], (double)HLdata[idxHl][5], (double)HLdata[idxHl][6] };
            double[] hlPs = new double[3] { (double)HLdata[idxHl][7], (double)HLdata[idxHl][8], (double)HLdata[idxHl][9] };
            double[] hlQs = new double[4] { (double)HLdata[idxHl][10], (double)HLdata[idxHl][11], (double)HLdata[idxHl][12], (double)HLdata[idxHl][13] };


            double[] mkpos = new double[3] { nnPoseData.mPos.X, nnPoseData.mPos.Y, nnPoseData.mPos.Z };

            object newmarkerpos = null;

            //try
            //{
                // Perfrom transformation of marker pos into KB frame
            matlab_.Feval("trans", 3, out newmarkerpos, mkpos, rbpos, rbquat, kbP, kbQ, hlPs, hlQs);
                

            //}
            //catch (Exception e)
            //{
            //    Console.WriteLine("Error in trans");
            //    Console.WriteLine(e.Message);
            //    Console.WriteLine("Attempting to re-initialize matlab");
            //    InitializeMatlab();

            //    // matlab_.Feval("trans", 3, out newmarkerpos, mkpos, rbpos, rbquat, kbP, kbQ, hlPs, hlQs);

            //    string debugOutput = "";
            //    debugOutput += string.Format("mkpos: {0:F6},{1:F6},{2:F6}\n", mkpos[0], mkpos[1], mkpos[2]);
            //    debugOutput += string.Format("rb-pos: {0:F6},{1:F6},{2:F6}\n", rbpos[0], rbpos[1], rbpos[2]);
            //    debugOutput += string.Format("rb-quat: {0:F6},{1:F6},{2:F6},{3:F6}\n", rbquat[0], rbquat[1], rbquat[2], rbquat[3]);
            //    debugOutput += string.Format("kb-pos: {0:F6},{1:F6},{2:F6}\n", kbP[0], kbP[1], kbP[2]);
            //    debugOutput += string.Format("kb-quat: {0:F6},{1:F6},{2:F6},{3:F6}\n", kbQ[0], kbQ[1], kbQ[2], kbQ[3]);
            //    debugOutput += string.Format("hl-pos: {0:F6},{1:F6},{2:F6}\n", hlPs[0], hlPs[1], hlPs[2]);
            //    debugOutput += string.Format("hl-quat: {0:F6},{1:F6},{2:F6},{3:F6}\n", hlQs[0], hlQs[1], hlQs[2], hlQs[3]);
            //    Console.WriteLine(debugOutput);
            //    return index;
            //}

            object[] res = newmarkerpos as object[];
            double xpos = Convert.ToDouble(res[0]);
            double ypos = Convert.ToDouble(res[1]);
            double zpos = Convert.ToDouble(res[2]);


            double[] newmarkerpos1 = new double[3] { xpos, ypos, zpos };

            // Log marker pos in KB frame to file
            LogKBData(newmarkerpos1);

            object result1 = null;
            // Console.WriteLine('p');
            //Console.WriteLine(index);
            //try
            //{
            matlab_.Feval("recognitioncopy", 2, out result1, newmarkerpos1, index, targetWord);
                //matlab_.Feval("recognitioncopy", 3, out result1, newmarkerpos1, index, targetWord);
            //}
            //catch (Exception e)
            //{
            //    Console.WriteLine("Error in recognitioncopy");
            //    Console.WriteLine(e.Message);
            //    Console.WriteLine("Attempting to re-initialize matlab");
            //    InitializeMatlab();

            //    // matlab_.Feval("trans", 3, out newmarkerpos, mkpos, rbpos, rbquat, kbP, kbQ, hlPs, hlQs);

            //    string debugOutput = "";
            //    debugOutput += string.Format("index: {0}\n", index);
            //    debugOutput += string.Format("mkpos: {0:F6},{1:F6},{2:F6}\n", newmarkerpos1[0], newmarkerpos1[1], newmarkerpos1[2]);
            //    debugOutput += string.Format("targetWord: {0}\n", targetWord);
            //    Console.WriteLine(debugOutput);
            //    return index;
            //}


            object[] res2 = result1 as object[];
            //Console.WriteLine('p');
            //Console.WriteLine(res2[0]);
            //Console.WriteLine('p');
            int preIndex = index;
            index = Convert.ToInt32(res2[0]);

            if (index == preIndex + 1)
            {
                Console.WriteLine("result: " + res2[1]);
                //Console.WriteLine('p');
            }


            // Console.WriteLine(index);
            return index;

        }



        // Handle new pose update event
        private void PoseDataReceived(HoloDataClient.HoloPose poseData)
        {
            // Console.WriteLine("\n");

            //Console.WriteLine("== HoloLens Data Update ==");
            string display = "";
            display += string.Format("\tpos ({0:N3}, {1:N3}, {2:N3})", poseData.camPos.X, poseData.camPos.Y, poseData.camPos.Z);
            display += string.Format("\t\trot ({0:N3}, {1:N3}, {2:N3}, {2:N3})", poseData.camRot.W, poseData.camRot.X, poseData.camRot.Y, poseData.camRot.Z);
            //Console.WriteLine(display);


            NatNetClient.NatNetPoseData nnPoseData = natNetClient_.FetchFrameData();                       

            //// Assemble log line
            //string log = "";            
            //log += string.Format("{0:F6},{1:F6},{2:F6},", poseData.camPos.X, poseData.camPos.Y, poseData.camPos.Z);
            //log += string.Format("{0:F8},{1:F8},{2:F8},{3:F8},", poseData.camRot.W, poseData.camRot.X, poseData.camRot.Y, poseData.camRot.Z);
            //log += string.Format("{0:F6},{1:F6},{2:F6},", nnPoseData.rbPos.X, nnPoseData.rbPos.Y, nnPoseData.rbPos.Z);
            //log += string.Format("{0:F8},{1:F8},{2:F8},{3:F8},", nnPoseData.rbRot.W, nnPoseData.rbRot.X, nnPoseData.rbRot.Y, nnPoseData.rbRot.Z);

            //// Add timestamp            
            //string timestamp = Math.Round((System.DateTime.Now - logStartTime_).TotalMilliseconds).ToString();

            //log += string.Format("{0}", timestamp);

            //WriteToLog(log);


            List<double>hldata = new List<double>() { poseData.kbPos.X, poseData.kbPos.Y, poseData.kbPos.Z, poseData.kbRot.W, poseData.kbRot.X, poseData.kbRot.Y, poseData.kbRot.Z, poseData.camPos.X, poseData.camPos.Y, poseData.camPos.Z, poseData.camRot.W, poseData.camRot.X, poseData.camRot.Y, poseData.camRot.Z };
            List<double> opdata = new List<double>() { nnPoseData.rbPos.X, nnPoseData.rbPos.Y, nnPoseData.rbPos.Z, nnPoseData.rbRot.W, nnPoseData.rbRot.X, nnPoseData.rbRot.Y, nnPoseData.rbRot.Z };
            HLdata.Add(hldata);
            OPdata.Add(opdata);

        }

        // Write KB positioning to log (HoloLens data)
        public void WriteToLogKB(string line)
        {
            //mPosKbLogList_.Add(line);
            //using (FileStream fs = new FileStream(outputFile2_, FileMode.Append))
            //{
            //    using (StreamWriter outputFile = new StreamWriter(fs))
            //    {
            //        outputFile.WriteLine(line);
            //    }
            //}
        }

        //// Write line to output file
        //public void WriteToLog(string line)
        //{            
        //    using (FileStream fs = new FileStream(outputFile_, FileMode.Append))
        //    {
        //        using (StreamWriter outputFile = new StreamWriter(fs))
        //        {
        //            outputFile.WriteLine(line);
        //        }
        //    }
        //}

        // Write line to output file
        public void WriteLogDataFile(string filename, List<string> lines)
        {
            using (FileStream fs = new FileStream(filename, FileMode.Append))
            {
                using (StreamWriter outputFile = new StreamWriter(fs))
                {
                    foreach (string line in lines)
                    {
                        outputFile.WriteLine(line);
                    }
                }
            }
        }

        // Write to marker and rigid body log (OptiTrack)
        public void WriteToLogMRB(string line)
        {
            //mrbLogList_.Add(line);
            //using (FileStream fs = new FileStream(outputFile1_, FileMode.Append))
            //{
            //    using (StreamWriter outputFile = new StreamWriter(fs))
            //    {
            //        outputFile.WriteLine(line);
            //    }
            //}
        }

        public void InterpretMessage(string messageString1)
        {
            //Console.Write(messageString1);
            logStartTime_ = System.DateTime.Now;

            //outputFile_ = outputFile_ + logStartTime_.ToString("_yyMMdd_hhmmss") + messageString1+ ".csv";
            //WriteToLog("# hl_pos_x,hl_pos_y,hl_pos_z,hl_rot_w,hl_rot_x,hl_rot_y,hl_rot_z,rb_pos_x,rb_pos_y,rb_pos_z,rb_rot_w,rb_rot_x,rb_rot_y,rb_rot_z,timestamp");
            mrbOutputFile_ = "markerandgaze" + logStartTime_.ToString("_yyMMdd_hhmmss_") + messageString1 + ".csv";
            kbTraceOutputFile_ = "kbtrace" + logStartTime_.ToString("_yyMMdd_hhmmss_") + messageString1 + ".csv";

            holoDataClient_.StartFetchLoop(2000);
            holoDataClient_.OnPoseUpdate = PoseDataReceived;

            nnStartFetchLoop(200, messageString1);
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

            CalibrationClient calClient = new CalibrationClient(holoClient, nnClient);

            Console.WriteLine("======================== STREAMING DATA (PRESS ESC TO EXIT) =====================\n");

            //if (!getInput(messageRequest, out messageString))
            //{
            //    break;
            //}

            // Send message to server
            string word = getInput(messageRequest);
            calClient.InterpretMessage(word);

            // Infinite loop
            while (!(Console.ReadKey().Key == ConsoleKey.Escape))
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
