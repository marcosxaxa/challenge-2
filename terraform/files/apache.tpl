#!/bin/bash

sudo yum update
sudo yum install httpd -y
sudo yum install php -y
sudo yum install mysql -y 
sudo yum install php-mysql -y

cat << 'EOF' >> /var/www/html/index.php
<?php
# Fill our vars and run on cli
# $ php -f db-connect-test.php

$dbname = 'challenge';
$dbuser = 'challenge';
$dbpass = 'Pass-123';
$dbhost = "${mysql_endpoint}:3110";

$connect = mysql_connect($dbhost, $dbuser, $dbpass) or die("Unable to Connect to '$dbhost'");
mysql_select_db($dbname) or die("Could not open the db '$dbname'");

$test_query = "SHOW TABLES FROM $dbname";
$result = mysql_query($test_query);

$tblCnt = 0;
while($tbl = mysql_fetch_array($result)) {
  $tblCnt++;
  #echo $tbl[0]."<br />\n";
}

if (!$tblCnt) {
  echo "There are no tables<br />\n";
} else {
  echo "There are $tblCnt tables in the database named $dbname<br />\n";
}

?>
EOF

sudo /etc/init.d/httpd start
