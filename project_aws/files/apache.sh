#!/bin/bash
# Script to install apache and provide a simple index.html

RANDOM_BACKGROUND=$(openssl rand -hex 3)
HOSTNAME=$(hostname)

sudo apt-get update && \
        sudo apt-get install apache2 -y

sudo systemctl enable apache2 && \
        sudo systemctl start apache2

sudo cat <<EOF > /var/www/html/index.html
<style>
@import url("https://fonts.googleapis.com/css?family=Bevan");

* {
    padding: 0;
    margin: 0;
    box-sizing: border-box;
}

body {
    background-color: $RANDOM_BACKGROUND;
    overflow: hidden;
}

p {
    font-family: "Bevan", cursive;
    font-size: 130px;
    margin: 10vh 0 0;
    text-align: center;
    letter-spacing: 5px;
    background-color: black;
    color: transparent;
    text-shadow: 2px 2px 3px rgba(255, 255, 255, 0.1);
    -webkit-background-clip: text;
    -moz-background-clip: text;
    background-clip: text;

    span {
        font-size: 1.2em;
    }
}
</style>
<p>Hello <span>World</span></p>
<p>$HOSTNAME</p>
EOF

