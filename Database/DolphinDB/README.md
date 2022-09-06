
- [Usage](#usage)
- [Reference](#reference)

## Usage
Change directory to current root one, which means the working directory should be "__local_setup__".

Note that the license "dolphindb.lic" is the community one, which allows only three nodes (1 cluster node, 2 data nodes, agent node doesn't count) running.

Replace the license with a new one if applicable.

0. Update the `image` version at `x-config` in corresponding "docker-compose", as well as the one in "Dokcerfile"
1. Run `./start.sh {mode}` to start containers, where mode is either "_community_" or "_distributed_"
2. Check if "localhost:8888" is accessible via the browser
   1. Log in with "admin" as user name and "123456" as the password
   2. Select data nodes and set them up and running by clicking the arrow button above
   3. Refresh and verify the state of data nodes is running
3. Download [DolphinDB GUI](https://www.dolphindb.com/gui_help/) via https://dolphindb.com/downloads/DolphinDB_GUI_V1.30.19.2.zip
   1. Unzip the compressed folder
   2. Make the script "gui.sh" or "gui.bat" executable
   3. Run the script to launch the GUI
4. Add server in UI for connection, where IP and port can be found in "docker-compose.yml", below is the example for default setting:
   - controller node:
     - Name: Controller
     - Host: localhost
     - Port: 8888
   - data node:
     - Name: P1-node
     - Host: 80.5.0.2
     - Port: 8711
5. Click "Test" to verify the connection
6. Run `./stop.sh {mode}` to shut down DolphinDB gracefully


## Reference
- DolphinDB Docker implementation: https://github.com/dolphindb/Tutorials_CN/tree/master/docker
- DolphinDB: https://www.dolphindb.com/
