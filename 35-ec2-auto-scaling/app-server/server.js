const http = require('http');
const fs = require('fs');
const os = require('os');
const path = require('path');

// Function to get the local IPv4 address of the machine
function getLocalIp() {
    const interfaces = os.networkInterfaces();
    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            if (iface.family === 'IPv4' && !iface.internal) {
                return iface.address; // Returns the first non-internal IPv4 address
            }
        }
    }
    return '127.0.0.1'; // Fallback
}

const PORT = 3000;
const serverIp = getLocalIp();

const server = http.createServer((req, res) => {
    // Read the HTML file
    fs.readFile(path.join(__dirname, 'index.html'), 'utf-8', (err, content) => {
        if (err) {
            res.writeHead(500, { 'Content-Type': 'text/plain' });
            res.end('Error loading index.html');
            return;
        }

        // Replace the placeholder with the actual server IP address
        const updatedHtml = content.replace('%%IP_ADDRESS%%', serverIp)
                                   .replace('%%%%', )

        // Send the updated HTML to the browser
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(updatedHtml);
    });
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running at http://localhost:${PORT}`);
    console.log(`Also accessible on your network at http://${serverIp}:${PORT}`);
});
