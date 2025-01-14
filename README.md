# DNS Tracker Script

This repository contains a Bash script designed to monitor and log DNS traffic. The script uses `tcpdump` to capture DNS queries and stores information about queried domains and their source IP addresses into a MySQL database.

## Features

1. **DNS Traffic Monitoring:** Captures DNS traffic on port 53 using `tcpdump`.
2. **Database Storage:** Logs queried domain names and their source IP addresses into a MySQL database.
3. **Duplicate Detection:** Updates the count of requests for previously logged domain names.
4. **Configurable Settings:** Reads database and DNS server details from a configuration file.
5. **Output Logging:** Logs processed domain names into a text file for additional reference.

## Prerequisites

1. **Linux Environment:** The script is intended for Linux-based systems.
2. **Dependencies:**
   - `tcpdump`: For capturing DNS traffic.
   - `mysql-client`: For interacting with the MySQL database.
3. **Database:**
   - MySQL database with necessary credentials and permissions.
4. **Configuration File:** A `config.ini` file located in `/opt/dns-tracker/` with the following format:

   ```ini
   db_name=your_database_name
   db_host=your_database_host
   db_username=your_database_username
   db_password=your_database_password
   dns_name=your_dns_name_ip
   dns_server_ip=your_dns_server_ip
   ```

## Table Schema

The script creates the following table if it does not exist:

```sql
CREATE TABLE IF NOT EXISTS `domains` (
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `ipsrc` TEXT NULL,
    `name` TEXT NULL,
    `count` INT NOT NULL DEFAULT 1
);
```

## How It Works

1. **Initialization:**
   - Reads database configuration from `config.ini`.
   - Exports environment variables for database connectivity.
   - Ensures the `domains` table exists in the database.

2. **Traffic Capture:**
   - Uses `tcpdump` to capture UDP traffic on port 53.
   - Filters domain names ending with `.com` or `.net`.
   - Extracts source IP addresses and queried domain names.

3. **Database Operations:**
   - Checks if the domain already exists in the `domains` table:
     - If not, inserts the domain name and source IP into the table.
     - If yes, increments the request count for the domain.

4. **Logging:**
   - Outputs processed domain names into `output.txt` located in `/opt/dns-tracker/`.

## Usage

1. **Clone the Repository:**
   ```bash
   git clone <repository-url>
   cd dns-tracker
   ```

2. **Set Up Configuration File:**
   Create a `config.ini` file in `/opt/dns-tracker/` with the required database and DNS details.

3. **Run the Script:**
   Make the script executable and run it:
   ```bash
   chmod +x script.sh
   ./script.sh
   ```

4. **Monitor Output:**
   - Real-time output of captured DNS traffic is displayed in the terminal.
   - Logged domain names are stored in `output.txt`.

## Example Output

**Terminal Output:**
```
DNS Server analysis is starting..
------------
domain.com
192.168.1.1
------------
```

**Database Content:**
| id  | ipsrc        | name        | count |
|-----|--------------|-------------|-------|
| 1   | 192.168.1.1  | domain.com  | 3     |

## Notes

- Ensure sufficient permissions for `tcpdump` to capture network traffic.
- Use proper database credentials and secure the `config.ini` file to prevent unauthorized access.
- The script assumes a specific format for domain queries (e.g., `.com`, `.net`). Modify the script if other TLDs need to be tracked.

## Troubleshooting

1. **`tcpdump: command not found`:**
   Install `tcpdump`:
   ```bash
   sudo apt install tcpdump
   ```

2. **MySQL Authentication Issues:**
   Verify credentials in the `config.ini` file and ensure the MySQL service is running.

3. **Permission Denied for `tcpdump`:**
   Run the script with superuser privileges:
   ```bash
   sudo ./script.sh
   ```

## Contributing

Feel free to open issues or submit pull requests for improvements and bug fixes.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

