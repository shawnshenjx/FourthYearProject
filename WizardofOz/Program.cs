﻿
using System.Collections;
using System.Collections.Generic;
using System.Numerics;

using NatNetML;
using System;
using System.Diagnostics;





namespace WOZconsole

{

    

    class NatNetClient
    {
        /*  [NatNet] Network connection configuration    */
        private static NatNetML.NatNetClientML mNatNet;    // The client instance
        private static string mStrLocalIP = "127.0.0.1";   // Local IP address (string)
        private static string mStrServerIP = "127.0.0.1";  // Server IP address (string)
        private static NatNetML.ConnectionType mConnectionType = ConnectionType.Multicast; // Multicast or Unicast mode


        /*  List for saving each of datadescriptors */
        private static List<NatNetML.DataDescriptor> mDataDescriptor = new List<NatNetML.DataDescriptor>();

        /*  Lists and Hashtables for saving data descriptions   */

        private static List<RigidBody> mRigidBodies = new List<RigidBody>();


        /*  boolean value for detecting change in asset */
        private static bool mAssetChanged = false;


        static void Main(string[] args)
        {
            Console.WriteLine("SampleClientML managed client application starting...\n");
            /*  [NatNet] Initialize client object and connect to the server  */
            connectToServer();                          // Initialize a NatNetClient object and connect to a server.

            Console.WriteLine("============================ SERVER DESCRIPTOR ================================\n");
            /*  [NatNet] Confirming Server Connection. Instantiate the server descriptor object and obtain the server description. */
            bool connectionConfirmed = fetchServerDescriptor();    // To confirm connection, request server description data

            if (connectionConfirmed)                         // Once the connection is confirmed.
            {
                Console.WriteLine("============================= DATA DESCRIPTOR =================================\n");
                Console.WriteLine("Now Fetching the Data Descriptor.\n");
                fetchDataDescriptor();                  //Fetch and parse data descriptor

                Console.WriteLine("============================= FRAME OF DATA ===================================\n");
                Console.WriteLine("Now Fetching the Frame Data\n");

                /*  [NatNet] Assigning a event handler function for fetching frame data each time a frame is received   */
                mNatNet.OnFrameReady += new NatNetML.FrameReadyEventHandler(fetchFrameData);

                Console.WriteLine("Success: Data Port Connected \n");



            }



            while (!(Console.KeyAvailable && Console.ReadKey().Key == ConsoleKey.Escape))
            {
                // Continuously listening for Frame data
                // Enter ESC to exit

                // Exception 

                if (mAssetChanged == true)
                    {
                        Console.WriteLine("\n===============================================================================\n");
                        Console.WriteLine("Change in the list of the assets. Refetching the descriptions");

                        /*  Clear out existing lists */
                        mDataDescriptor.Clear();

                        mRigidBodies.Clear();
 

                        /* [NatNet] Re-fetch the updated list of descriptors  */
                        fetchDataDescriptor();
                        Console.WriteLine("===============================================================================\n");
                        mAssetChanged = false;
                    }
            }
            /*  [NatNet] Disabling data handling function   */
            mNatNet.OnFrameReady -= fetchFrameData;

            /*  Clearing Saved Descriptions */
            mRigidBodies.Clear();

            mNatNet.Disconnect();
        }


        static void fetchFrameData(NatNetML.FrameOfMocapData data, NatNetML.NatNetClientML client)
        {

            if ((data.bTrackingModelsChanged == true || data.nRigidBodies != mRigidBodies.Count))
            {
                mAssetChanged = true;
            }

            /*  Processing */

            int index = 1;

            if (data.iFrame % 1 == 0)
            {
                if (data.bRecording == false)
                    Console.WriteLine("Frame #{0} Received:", data.iFrame);
                else if (data.bRecording == true)
                    Console.WriteLine("[Recording] Frame #{0} Received:", data.iFrame);

                index = NatNetClient.processFrameData(data,  index);

              

            }
        }

        private static int processFrameData(NatNetML.FrameOfMocapData data, int index)
        {
            int index2 = 0;


            string startupPath = Environment.CurrentDirectory;
            Console.WriteLine(startupPath);
            string pathCmd = string.Format("cd {0}/../../..", startupPath);
            Console.WriteLine(pathCmd);

            // Create the MATLAB instance 
            MLApp.MLApp matlab = new MLApp.MLApp();

            // Change to the directory where the function is located 
            matlab.Execute(pathCmd);


            Console.WriteLine("labeled markers: " + data.nMarkers);

            /*  Parsing Rigid Body Frame Data   */
            for (int i = 0; i < mRigidBodies.Count; i++)
            {
                int rbID = mRigidBodies[i].ID;              // Fetching rigid body IDs from the saved descriptions

                for (int j = 0; j < data.nRigidBodies; j++)
                {
                    if (rbID == data.RigidBodies[j].ID)      // When rigid body ID of the descriptions matches rigid body ID of the frame data.
                    {
                        NatNetML.RigidBody rb = mRigidBodies[i];                // Saved rigid body descriptions
                        NatNetML.RigidBodyData rbData = data.RigidBodies[j];    // Received rigid body descriptions

                        if (rbData.Tracked == true)
                        {


                            NatNetML.Marker marker = data.LabeledMarkers[i];

                            int mID = marker.ID;
                            Console.WriteLine("\tMarker ({0}):", mID);
                            Console.WriteLine("\t\tpos ({0:N3}, {1:N3}, {2:N3})", marker.x, marker.y, marker.z);


                            Console.WriteLine("\tRigidBody ({0}):", rb.Name);
                            Console.WriteLine("\t\tpos ({0:N3}, {1:N3}, {2:N3})", rbData.x, rbData.y, rbData.z);

                            // Rigid Body Euler Orientation
                            float[] rbquat = new float[4] { rbData.qx, rbData.qy, rbData.qz, rbData.qw };
                            float[] rbpos = new float[3] { rbData.x, rbData.y, rbData.z };
                            float[] mkpos = new float[3] { marker.x, marker.y, marker.z };
                       

                            object newmarkerpos = null;


                            matlab.Feval("transformation", 3,out newmarkerpos, mkpos, rbquat, rbpos);

                            object[] res = newmarkerpos as object[];


                            float xpos = Convert.ToSingle(res[0]);
                            float ypos = Convert.ToSingle(res[1]);
                            float zpos = Convert.ToSingle(res[2]);


                            float[] newmarkerpos1 = new float[3] { xpos, ypos, zpos };


                            float[] kbquat = { 10, 20, 30,21 };
                            float[] kbpos  = { 20, 30, 40 };
                            float[] hmdquat = { 20, 30, 40 ,21};

                            object newmarkerpos2 = null;

                            matlab.Feval("transformationLL",3, out newmarkerpos2, newmarkerpos1, kbquat, hmdquat,kbpos);

                            object[] res1 = newmarkerpos2 as object[];


                            float xpos_new = Convert.ToSingle(res1[0]);
                            float ypos_new = Convert.ToSingle(res1[1]);
                            float zpos_new = Convert.ToSingle(res1[2]);

                            float[] newmarkerpos3 = new float[3] { xpos_new, ypos_new, zpos_new };

                            float[] keypos = new float[] { };

                            


                            

                            object result1 = null;

                            matlab.Feval("recognition", 2, out result1, newmarkerpos1, index);

                            object[] res2 = result1 as object[];

                            Console.WriteLine(res2[0]);
                            Console.WriteLine(res2[1]);


                            index2 = Convert.ToInt32(res2[1]);
                           

                        }
                        else
                        {
                            Console.WriteLine("\t{0} is not tracked in current frame", rb.Name);
                        }
                    }
                }
            }

            return index2;
        }


        
        static void connectToServer()
        {
            /*  [NatNet] Instantiate the client object  */
            mNatNet = new NatNetML.NatNetClientML();

            /*  [NatNet] Checking verions of the NatNet SDK library  */
            int[] verNatNet = new int[4];           // Saving NatNet SDK version number
            verNatNet = mNatNet.NatNetVersion();
            Console.WriteLine("NatNet SDK Version: {0}.{1}.{2}.{3}", verNatNet[0], verNatNet[1], verNatNet[2], verNatNet[3]);

            /*  [NatNet] Connecting to the Server    */
            Console.WriteLine("\nConnecting...\n\tLocal IP address: {0}\n\tServer IP Address: {1}\n\n", mStrLocalIP, mStrServerIP);

            NatNetClientML.ConnectParams connectParams = new NatNetClientML.ConnectParams();
            connectParams.ConnectionType = mConnectionType;
            connectParams.ServerAddress = mStrServerIP;
            connectParams.LocalAddress = mStrLocalIP;
            mNatNet.Connect(connectParams);
        } 
        

        static bool fetchServerDescriptor()
        {
            NatNetML.ServerDescription m_ServerDescriptor = new NatNetML.ServerDescription();
            int errorCode = mNatNet.GetServerDescription(m_ServerDescriptor);

            if (errorCode == 0)
            {
                Console.WriteLine("Success: Connected to the server\n");
                parseSeverDescriptor(m_ServerDescriptor);
                return true;
            }
            else
            {
                Console.WriteLine("Error: Failed to connect. Check the connection settings.");
                Console.WriteLine("Program terminated (Enter ESC to exit)");
                return false;
            }
        }

        static void parseSeverDescriptor(NatNetML.ServerDescription server)
        {
            Console.WriteLine("Server Info:");
            Console.WriteLine("\tHost: {0}", server.HostComputerName);
            Console.WriteLine("\tApplication Name: {0}", server.HostApp);
            Console.WriteLine("\tApplication Version: {0}.{1}.{2}.{3}", server.HostAppVersion[0], server.HostAppVersion[1], server.HostAppVersion[2], server.HostAppVersion[3]);
            Console.WriteLine("\tNatNet Version: {0}.{1}.{2}.{3}\n", server.NatNetVersion[0], server.NatNetVersion[1], server.NatNetVersion[2], server.NatNetVersion[3]);
        }

        static void fetchDataDescriptor()
        {
            /*  [NatNet] Fetch Data Descriptions. Instantiate objects for saving data descriptions and frame data    */
            bool result = mNatNet.GetDataDescriptions(out mDataDescriptor);
            if (result)
            {
                Console.WriteLine("Success: Data Descriptions obtained from the server.");
                parseDataDescriptor(mDataDescriptor);
            }
            else
            {
                Console.WriteLine("Error: Could not get the Data Descriptions");
            }
            Console.WriteLine("\n");
        }

        static void parseDataDescriptor(List<NatNetML.DataDescriptor> description)
        {
            //  [NatNet] Request a description of the Active Model List from the server. 
            //  This sample will list only names of the data sets, but you can access 
            int numDataSet = description.Count;
            Console.WriteLine("Total {0} data sets in the capture:", numDataSet);

            for (int i = 0; i < numDataSet; ++i)
            {
                int dataSetType = description[i].type;
                // Parse Data Descriptions for each data sets and save them in the delcared lists and hashtables for later uses.
                switch (dataSetType)
                {
                    case ((int)NatNetML.DataDescriptorType.eMarkerSetData):
                        NatNetML.MarkerSet mkset = (NatNetML.MarkerSet)description[i];
                        Console.WriteLine("\tMarkerSet ({0})", mkset.Name);
                        break;

                    case ((int)NatNetML.DataDescriptorType.eRigidbodyData):
                        NatNetML.RigidBody rb = (NatNetML.RigidBody)description[i];
                        Console.WriteLine("\tRigidBody ({0})", rb.Name);

                        // Saving Rigid Body Descriptions
                        mRigidBodies.Add(rb);
                        break;

                    default:
                        // When a Data Set does not match any of the descriptions provided by the SDK.
                        Console.WriteLine("\tError: Invalid Data Set");
                        break;
                }
            }
        }





    }
}
