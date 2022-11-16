import subprocess
import os
from tbselenium.tbdriver import TorBrowserDriver

site = "check.torproject.org"

try:
    process = subprocess.Popen(['sudo', 'tcpdump', '-l', '-i', 'eth0', '-w', 'trace.pcap'], stdout=subprocess.PIPE)

    with TorBrowserDriver("/path/to/tor-browser_en-US/") as driver:
        driver.load_url("https://" + site, wait_on_page=20)

    cmd = "sudo kill " + str(process.pid)
    os.system(cmd)
except OSError, e:
    print e