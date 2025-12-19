#!/bin/bash

# Packages check
for pkg in figlet python php apache2 lsof; do
    if ! command -v $pkg &> /dev/null; then
        echo "Installing $pkg..."
        pkg install $pkg -y
    fi
done

# Colors
G='\033[1;32m'
R='\033[1;31m'
Y='\033[1;33m'
C='\033[1;36m'
W='\033[1;37m'
NC='\033[0m'

# Banner
banner() {
    clear
    echo -e "$C"
    figlet -f slant "NRX server"
    echo -e "$G ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "$Y  [★] Author  : $W NRXcyberLearner"
    echo -e "$Y  [★] Brand   : $W NRXcyber"
    echo -e "$Y  [★] Virson  : 1.0 "
    echo -e "$G ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
}

# Typewriter
type_anim() {
    local text="$1"
    for (( i=0; i<${#text}; i++ )); do
        echo -ne "${text:$i:1}"
        sleep 0.02
    done
    echo ""
}

# Main Server Function
start_server() {
    local type=$1
    local def_port=$2

    banner
    echo -e "$C [>] होस्ट करने के लिए पाथ डालें (जैसे: /sdcard/ या current के लिए Enter):$NC"
    read -p " Path > " target_path
    target_path=${target_path:-$(pwd)}

    # Fix: Correcting Path if it's relative
    if [[ ! -d "$target_path" ]]; then
        echo -e "$R [!] Error: '$target_path' फोल्डर नहीं मिला!$NC"
        sleep 2
        return
    fi

    echo -e "$C [>] पोर्ट चुनें (Default $def_port):$NC"
    read -p " Port > " port
    port=${port:-$def_port}

    # Fix: Better Port Check
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        echo -e "$R [!] पोर्ट $port पहले से इस्तेमाल में है!$NC"
        sleep 2
        return
    fi

    echo -e "$Y [*] सर्वर शुरू हो रहा है... $NC"
    
    # Path navigation and execution
    cd "$target_path" || return
    
    if [ "$type" == "Python" ]; then
        python3 -m http.server $port > /dev/null 2>&1 &
        srv_pid=$!
    elif [ "$type" == "PHP" ]; then
        php -S localhost:$port > /dev/null 2>&1 &
        srv_pid=$!
    elif [ "$type" == "Apache" ]; then
        # Apache requires config changes for custom path, so we use a simpler approach
        echo "Apache default setup start..."
        apachectl start
        srv_pid="Apache_Service"
    fi

    echo -e "$G [✔] $type सर्वर सफलतापूर्वक शुरू हुआ!$NC"
    echo -e "$W [i] Path : $target_path"
    echo -e "$W [i] URL  : http://localhost:$port"
    echo -e "$G ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "$R [!] सर्वर बंद करने के लिए 'STOP' टाइप करें या Enter दबाएं$NC"
    read -p " NRX > " cmd
    
    # Cleaning up
    if [ "$type" == "Apache" ]; then
        apachectl stop
    else
        kill $srv_pid 2>/dev/null
    fi
    
    cd - > /dev/null
    echo -e "$Y [!] सर्वर बंद कर दिया गया है।$NC"
    sleep 2
}

# Main Menu
while true; do
    banner
    echo -e "$B [1]$W Python3 HTTP Server (Recommended)"
    echo -e "$B [2]$W PHP Built-in Server"
    echo -e "$B [3]$W Apache (httpd) Default"
    echo -e "$B [4]$W Kill All Active Servers (Force)"
    echo -e "$B [5]$W Exit Tool"
    echo ""
    echo -ne "$G NRX-Cyber-Select > $NC"
    read choice

    case $choice in
        1) start_server "Python" 8000 ;;
        2) start_server "PHP" 8080 ;;
        3) start_server "Apache" 8080 ;;
        4) 
            echo -e "$R [*] सभी सवर्र बंद किए जा रहे हैं...$NC"
            pkill python3; pkill php; apachectl stop
            sleep 2
            ;;
        5) 
            type_anim "$Y [*] NRXcyber टूल का उपयोग करने के लिए धन्यवाद। अलविदा!$NC"
            exit 0
            ;;
        *) 
            echo -e "$R [*] गलत विकल्प!$NC"
            sleep 1 
            ;;
    esac
done
