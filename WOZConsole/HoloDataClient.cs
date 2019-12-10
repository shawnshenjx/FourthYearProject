using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;
using System.Numerics;


namespace CalibrationConsole
{
    class HoloDataClient
    {
        public struct HoloPose
        {
            public Vector3 camPos;
            public Quaternion camRot;
            public Vector3 kbPos;
            public Quaternion kbRot;
        }

        public Action<HoloPose> OnPoseUpdate; 

        private TcpClient client_ = null;
                
        public void Disconnect()
        {
            SendMessage(client_, "kb_client_close");
        }

        public bool ConnectToServer(string address, int port = 11001) {

            bool connected = true;

            // Establish connection to HoloServer            
            string serverIpAddressString = address;
            client_ = Connect(serverIpAddressString, port);

            // Check if client is connected
            if (!client_.Connected)
            {
                Console.WriteLine("Failed to connect.");
                connected = false;
            }
            else
            {
                Console.WriteLine("Connected to HoloServer at: " + address);
            }

            return connected;
        }

        public void StartFetchLoop(int interval = 1000)
        {
            // Create a timer and set a two second interval.
            System.Timers.Timer timer = new System.Timers.Timer();
            timer.Interval = interval;

            // Hook up the Elapsed event for the timer. 
            timer.Elapsed += fetchHoloLensData;

            // Start the timer
            timer.Enabled = true;
        }


        // Establish connection to HoloLens server
        TcpClient Connect(String server, int port)
        {
            TcpClient client = new TcpClient();

            try
            {
                client = new TcpClient(server, port);
            }
            catch (ArgumentNullException e)
            {
                Console.WriteLine("ArgumentNullException: {0}", e);
            }
            catch (SocketException e)
            {
                Console.WriteLine("SocketException: {0}", e);
            }

            return client;
        }

        private void fetchHoloLensData(Object source, System.Timers.ElapsedEventArgs e)
        {
            try
            {
                SendMessage(client_, "kb_cam_pose_data");
                string reply = ReadMessage(client_);

                string[] cols = reply.Split(',');
                if (cols.Length == 15)
                {   
                    HoloPose hlPose = new HoloPose();
                    hlPose.kbPos = new Vector3(float.Parse(cols[0]), float.Parse(cols[1]), float.Parse(cols[2]));
                    // NOTE Quaternion constructed with x,y,z,w                                            
                    hlPose.kbRot = new Quaternion(float.Parse(cols[4]), float.Parse(cols[5]), float.Parse(cols[6]), float.Parse(cols[3]));
                    hlPose.camPos = new Vector3(float.Parse(cols[7]), float.Parse(cols[8]), float.Parse(cols[9]));
                    // NOTE Quaternion constructed with x,y,z,w
                    hlPose.camRot = new Quaternion(float.Parse(cols[11]), float.Parse(cols[12]), float.Parse(cols[13]), float.Parse(cols[10]));

                    OnPoseUpdate.Invoke(hlPose);
                }
            }
            catch (SystemException exception)
            {
                Console.WriteLine("Exception: {0}", exception);
            }
        }

        private void SendMessage(TcpClient client, string message)
        {
            // Translate the passed message into ASCII and store it as a Byte array.
            Byte[] data = System.Text.Encoding.ASCII.GetBytes(message);

            // Get a client stream for writing.
            NetworkStream stream = client.GetStream();

            // Send the message to the connected TcpServer. 
            stream.Write(data, 0, data.Length);

            // Report what was sent to console
            // Console.WriteLine("Sent: {0}", message);

            // Flush the stream
            stream.Flush();
        }

        static string ReadMessage(TcpClient client)
        {
            // Buffer to store the response bytes.
            Byte[] data = new Byte[256];

            // String to store the response ASCII representation.
            String responseData = String.Empty;

            // Get a client stream for writing.
            NetworkStream stream = client.GetStream();

            // Read the first batch of the TcpServer response bytes.
            Int32 bytes = stream.Read(data, 0, data.Length);
            responseData = System.Text.Encoding.ASCII.GetString(data, 0, bytes);

            // Report what was received to console
            // Console.WriteLine("Received: {0}", responseData);

            return responseData;
        }


        public void SendhHoloLensData()
        {
            try
            {
                SendMessage(client_, "kb_add_word\tplayful");
              
            }
            catch (SystemException exception)
            {
                Console.WriteLine("Exception: {0}", exception);
            }
        }


    }
}
