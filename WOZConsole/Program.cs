// Console application adapted from NatNet SDK SampleClientML.cs

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
        private string outputFile_ = "calibration_log";
        private string outputFile_ = "markerandgaze";
        private DateTime logStartTime_;
        private static int index = 1;
        private static List<List<double>> HLdata = new List<List<double>>();
        private static List<List<double>> OPdata = new List<List<double>>();


        // Constructor
        CalibrationClient(HoloDataClient holoDataClient, NatNetClient natNetClient)
        {




            logStartTime_ = System.DateTime.Now;
            outputFile_ = outputFile_ + logStartTime_.ToString("_yyMMdd_hhmmss") + ".csv";
            WriteToLog("# hl_pos_x,hl_pos_y,hl_pos_z,hl_rot_w,hl_rot_x,hl_rot_y,hl_rot_z,rb_pos_x,rb_pos_y,rb_pos_z,rb_rot_w,rb_rot_x,rb_rot_y,rb_rot_z,timestamp");

            holoDataClient_ = holoDataClient;
            natNetClient_ = natNetClient;

            holoDataClient_.StartFetchLoop(2000);
            holoDataClient_.OnPoseUpdate = PoseDataReceived;

            nnStartFetchLoop(20);

        }



        public void nnStartFetchLoop(int interval = 1000)
        {
            // Create a timer and set a two second interval.
            System.Timers.Timer timer = new System.Timers.Timer();
            timer.Interval = interval;

            // Hook up the Elapsed event for the timer. 
            timer.Elapsed += ProcessAllData;

            // Start the timer
            timer.Enabled = true;
        }



        // Handle new pose update event
        private void ProcessAllData()
        {

            string startupPath = Environment.CurrentDirectory;
            //Console.WriteLine(startupPath);
            string pathCmd = string.Format("cd {0}\\..\\..", startupPath);
            //Console.WriteLine(pathCmd);

            // Create the MATLAB instance 
            MLApp.MLApp matlab = new MLApp.MLApp();

            // Change to the directory where the function is located 
            matlab.Execute(pathCmd);

            NatNetClient.NatNetPoseData nnPoseData = natNetClient_.FetchFrameData();

            index = handledata( nnPoseData, index);


            if (index > 10)
            {
                Console.Write("helloworld");
                HoloDataClient_.sendhHoloLensData();
            }

            LogData(nnPoseData);
           

        }

        private void LogData(NatNetClient.NatNetPoseData nnPoseData)
        {
            string log = "";
            log += string.Format("{0:F6},{1:F6},{2:F6},", nnPoseData.rbPos.x, nnPoseData.rbPos.y, nnPoseData.rbPos.z);
            log += string.Format("{0:F8},{1:F8},{2:F8},{3:F8},", nnPoseData.rbRot.W, nnPoseData.rbRot.X, nnPoseData.rbRot.Y, nnPoseData.rbRot.Z);
            log += string.Format("{0:F8},{1:F8},{2:F8},{3:F8},", nnPoseData.rbRot.W, nnPoseData.rbRot.X, nnPoseData.rbRot.Y, nnPoseData.rbRot.Z);


            // Add timestamp            
            string timestamp = Math.Round((System.DateTime.Now - logStartTime_).TotalMilliseconds).ToString();
            log += string.Format("{0}", timestamp);

            WriteToLogMRB(log);
        }

        private int handledata(NatNetClient.NatNetPoseData nnPoseData, int index)
        {
            int idxHl = 0;

            double[] rbpos = new double[3] { (double)HLdata[idxHl][0], (double)HLdata[idxHl][1], (double)HLdata[idxHl][2] };
            double[] rbquat = new double[4] { (double)HLdata[idxHl][3], (double)HLdata[idxHl][4], (double)HLdata[idxHl][5], (double)HLdata[idxHl][6] };
            double[] kbP = new double[3] { (double)HLdata[idxHl][0], (double)HLdata[idxHl][1], (double)HLdata[idxHl][2] };
            double[] kbQ = new double[4] { (double)HLdata[idxHl][3], (double)HLdata[idxHl][4], (double)HLdata[idxHl][5], (double)HLdata[idxHl][6] };
            double[] hlPs = new double[3] { (double)HLdata[idxHl][7], (double)HLdata[idxHl][8], (double)HLdata[idxHl][9] };
            double[] hlQs = new double[4] { (double)HLdata[idxHl][10], (double)HLdata[idxHl][11], (double)HLdata[idxHl][12], (double)HLdata[idxHl][13] };


            double[] mkpos = new double[3] { nnPoseData.mPos.x, nnPoseData.mPos.y, nnPoseData.mPos.z };


            matlab.Feval("trans", 3, out newmarkerpos, mkpos, rbpos, rbquat, kbP, kbQ, hlPs, hlQs);
            object[] res = newmarkerpos as object[];


            double xpos = Convert.ToDouble(res[0]);
            double ypos = Convert.ToDouble(res[1]);
            double zpos = Convert.ToDouble(res[2]);


            double[] newmarkerpos1 = new double[3] { xpos, ypos, zpos };


            object result1 = null;
            //Console.WriteLine(index);
            matlab.Feval("recognition", 2, out result1, newmarkerpos1, index);

            object[] res2 = result1 as object[];

            Console.WriteLine(res2[0]);
            Console.WriteLine(res2[1]);

            index = Convert.ToInt32(res2[0]);
            return index;

        }



        // Handle new pose update event
        private void PoseDataReceived(HoloDataClient.HoloPose poseData)
        {
            Console.WriteLine("\n");

            Console.WriteLine("== HoloLens Data Update ==");
            string display = "";
            display += string.Format("\tpos ({0:N3}, {1:N3}, {2:N3})", poseData.camPos.X, poseData.camPos.Y, poseData.camPos.Z);
            display += string.Format("\t\trot ({0:N3}, {1:N3}, {2:N3}, {2:N3})", poseData.camRot.W, poseData.camRot.X, poseData.camRot.Y, poseData.camRot.Z);
            Console.WriteLine(display);


            NatNetClient.NatNetPoseData nnPoseData = natNetClient_.FetchFrameData();                       

            // Assemble log line
            string log = "";            
            log += string.Format("{0:F6},{1:F6},{2:F6},", poseData.camPos.X, poseData.camPos.Y, poseData.camPos.Z);
            log += string.Format("{0:F8},{1:F8},{2:F8},{3:F8},", poseData.camRot.W, poseData.camRot.X, poseData.camRot.Y, poseData.camRot.Z);
            log += string.Format("{0:F6},{1:F6},{2:F6},", nnPoseData.rbPos.X, nnPoseData.rbPos.Y, nnPoseData.rbPos.Z);
            log += string.Format("{0:F8},{1:F8},{2:F8},{3:F8},", nnPoseData.rbRot.W, nnPoseData.rbRot.X, nnPoseData.rbRot.Y, nnPoseData.rbRot.Z);

            // Add timestamp            
            string timestamp = Math.Round((System.DateTime.Now - logStartTime_).TotalMilliseconds).ToString();

            log += string.Format("{0}", timestamp);

            WriteToLog(log);


            List<string> hldata = new List<double>(poseData.kbPos.X, poseData.kbPos.Y, poseData.kbPos.Z, poseData.kbRot.W, poseData.kbRot.X, poseData.kbRot.Y, poseData.kbRot.Z,poseData.camPos.X, poseData.camPos.Y, poseData.camPos.Z, poseData.camRot.W, poseData.camRot.X, poseData.camRot.Y, poseData.camRot.Z);
            List<string> opdata = new List<double>(nnPoseData.rbPos.X, nnPoseData.rbPos.Y, nnPoseData.rbPos.Z, nnPoseData.rbRot.W, nnPoseData.rbRot.X, nnPoseData.rbRot.Y, nnPoseData.rbRot.Z);
            HLdata.Add(hldata);
            OPdata.Add(opdata);

        }

        // Write line to output file
        public void WriteToLog(string line)
        {            
            using (FileStream fs = new FileStream(outputFile_, FileMode.Append))
            {
                using (StreamWriter outputFile = new StreamWriter(fs))
                {
                    outputFile.WriteLine(line);
                }
            }
        }

        public void WriteToLogMRB(string line)
        {
            using (FileStream fs = new FileStream(outputFile1_, FileMode.Append))
            {
                using (StreamWriter outputFile = new StreamWriter(fs))
                {
                    outputFile.WriteLine(line);
                }
            }
        }





        // Main function
        static void Main(string[] args)
        {
            Console.WriteLine("Calibration client starting...\n");

            // Initialize HoloDataClient
            HoloDataClient holoClient = new HoloDataClient();
            holoClient.ConnectToServer("192.168.1.101",11001);
            //holoClient.ConnectToServer("127.0.0.1", 11001);
            
            // Initialize NatNetClient
            NatNetClient nnClient = new NatNetClient();
            nnClient.Connect();

            CalibrationClient calClient = new CalibrationClient(holoClient, nnClient);

            Console.WriteLine("======================== STREAMING DATA (PRESS ESC TO EXIT) =====================\n");

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
