#!/bin/bash

sudo apt-get update -y

sudo apt-get install apache2 -y

sudo systemctl start apache2

sudo systemctl enable apache2

echo "<? <!DOCTYPE html>
<html>
<body>

<h1>This is KRISHNA'S page</h1>

<p>Hello folks.....</p>

</body>
</html> " > /var/www/html/mypage.html

sudo chmod 777  /var/www/html/mypage.html