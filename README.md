Automated Backup Using rsync and API Notification
This script automates the process of backing up files from a local directory to a remote server using rsync. It logs the transfer details and sends a notification via an API after the backup completes. The script includes SSH key authentication for secure transfers, and it can be easily set up to run on a schedule.

Features
Backup Automation: Syncs files from a local directory to a remote server using rsync.
Progress and Statistics: Provides detailed logs and statistics of the transfer.
API Notification: Sends a JSON payload to a specified API endpoint after the backup completes.
Log File: Logs the backup status and file size transferred for future reference.
SSH Authentication: Uses SSH key authentication for secure communication with the remote server.
Prerequisites
Before using this script, you need the following:

rsync: Installed on both local and remote servers.
SSH Key: Ensure that SSH key-based authentication is set up between the local machine and the remote server.
API Endpoint: You need an API endpoint that can receive a JSON payload. This is typically used for monitoring purposes.
cron: Optional but recommended for scheduling regular backups.
Setup
Clone the Repository (if applicable)

If you have not already, clone the repository where the script resides.

bash
Copy code
git clone https://github.com/naflan121/Rsync-Backup-Script.git
cd Rsync-Backup-Script
Edit the Script

Open the backup_script.sh file and modify the following variables to suit your environment:

SOURCE_DIR: The local directory you want to back up (e.g., /var/www/your_source_directory).
DEST_DIR: The remote server and destination directory (e.g., user@your.remote.server:/path/to/backup/destination/).
SSH_KEY: The path to your SSH private key (e.g., $HOME/.ssh/your_ssh_key).
LOG_FILE: The path to your log file (e.g., /path/to/your_log_directory/backup_log.txt).
API_URL: The endpoint where the API notification will be sent (e.g., https://your_api_endpoint.url).
Ensure that you replace all the placeholders with your actual values.

Install Dependencies

You need rsync and curl to be installed on your local machine. Install them using the following commands if not already installed:

For Debian/Ubuntu:

bash
Copy code
sudo apt update
sudo apt install rsync curl
For CentOS/RHEL:

bash
Copy code
sudo yum install rsync curl
Make the Script Executable

Run the following command to give the script execute permissions:

bash
Copy code
chmod +x backup_script.sh
Running the Script
To manually run the backup script, simply execute it:

bash
Copy code
./backup_script.sh
This will:

Start the backup process with rsync.
Log the details of the backup to the specified log file.
Send a notification to the API endpoint with the backup details.
Automating with cron
To automatically run this script at scheduled intervals, you can set it up with cron.

Step 1: Edit the cron jobs
Run the following command to open your crontab for editing:

bash
Copy code
crontab -e
Step 2: Add a new cron job
To run the backup script every day at midnight, for example, add the following line to your crontab:

bash
Copy code
0 0 * * * /path/to/backup_script.sh >> /path/to/your_log_directory/cron_backup_log.txt 2>&1
This cron job does the following:

Runs the script at midnight every day (0 0 * * *).
Redirects both standard output and error messages to cron_backup_log.txt.
Step 3: Save and exit
In vi (default editor), press Esc, type :wq, and hit Enter.
In nano, press Ctrl + O to save, then Ctrl + X to exit.
Viewing Logs
Backup Log: After each run, the script logs the total transferred size to the file specified by LOG_FILE. Check this log to monitor the backup progress.

Cron Log: If you're running the script via cron, you can view the cron-specific logs (standard output and errors) in cron_backup_log.txt (or whatever you named it).

API Payload
The script sends a POST request to the configured API_URL with the following JSON payload:

json
Copy code
{
    "success": true,
    "subject": "System Backup",
    "start_time": "2024-12-12 00:00:00",
    "end_time": "2024-12-12 00:30:00",
    "file_name": "Files",
    "file_size": "2.50 GB",
    "backup_server": "your_backup_server_ip",
    "backup_name": "System Backup"
}
Make sure your API endpoint is capable of handling and processing this JSON data.