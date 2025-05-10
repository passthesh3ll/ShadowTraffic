#!/bin/bash

# URL of the top sites list (JSON format)
SITES_URL="https://raw.githubusercontent.com/Kikobeats/top-sites/master/top-sites.json"
UA_URL="https://raw.githubusercontent.com/microlinkhq/top-user-agents/refs/heads/master/src/index.json"
headers=(
  "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
  "Accept-Encoding: gzip, deflate, br"
  "Connection: keep-alive"
  "Upgrade-Insecure-Requests: 1"
  "Accept-Language: en-US,en;q=0.9"
)

# Color codes for output
RED="\033[1;31m"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN="\033[1;36m"
BLUE='\033[0;34m'
RESET='\033[0m'

# Display custom ASCII art text
echo -e "${CYAN}"
echo '  ________.__               .___            ___________              _____  _____.__        '
echo ' /   _____|  |__ _____    __| _/______  _  _\__    _______________ _/ _____/ ____|__| ____  '
echo ' \_____  \|  |  \\__  \  / __ |/  _ \ \/ \/ / |    |  \_  __ \__  \\   __\\   __\|  _/ ___\ '
echo ' /        |   Y  \/ __ \/ /_/ (  <_> \     /  |    |   |  | \// __ \|  |   |  |  |  \  \___ '
echo '/_______  |___|  (____  \____ |\____/ \/\_/   |____|   |__|  (____  |__|   |__|  |__|\___  >'
echo '        \/     \/     \/     \/                                   \/                     \/  '
echo '                    Privacy Generator by Traffic Flow            @passthesh3ll              '
echo -e "${RESET}"


# Fetch and store full URLs from the JSON list (rootDomain + "www.")
sites=()
while IFS= read -r site; do
  sites+=("https://www.$site")
done < <(curl -s "$SITES_URL" | jq -r '.[].rootDomain')

# Exit if the list is empty
if [ ${#sites[@]} -eq 0 ]; then
  echo -e "${RED}Error: No sites found.${RESET}"
  exit 1
fi

# Fetch and store user-agents
user_agents=()
while IFS= read -r ua; do
  user_agents+=("$ua")
done < <(curl -s "$UA_URL" | jq -r '.[]')

# Exit if the user-agent list is empty
if [ ${#user_agents[@]} -eq 0 ]; then
  echo -e "${RED}Error: No user-agents found.${RESET}"
  exit 1
fi

# Output number of loaded sites/ua
echo -e "${GREEN}Loaded ${#sites[@]} sites.${RESET}"
echo -e "${GREEN}Loaded ${#user_agents[@]} user agents.${RESET}\n"

# Infinite loop for visiting random sites
while true; do
  # Pick a random site from the list
  random_site="${sites[RANDOM % ${#sites[@]}]}"

  # Pick a random user-agent from the list
  random_ua="${user_agents[RANDOM % ${#user_agents[@]}]}"

  # Output current site and user-agent
  echo -e "${YELLOW}Visiting site:${RESET} $random_site"
  echo -e "${YELLOW}Using User-Agent:${RESET} $random_ua"

  # Visit the site using the chosen user-agent and print the curl output (response code)
  curl_output=$(curl -s -A "$random_ua" -w "%{http_code}\n" --compressed -L "$random_site" \
  -H "${headers[0]}" -H "${headers[1]}" -H "${headers[2]}" -H "${headers[3]}" -H "${headers[4]}" -o /dev/null)

  # Check if the visit was successful by examining the HTTP status code
  if [ "$curl_output" -eq 200 ]; then
    echo -e "${GREEN}Successfully visited $random_site (HTTP Status: 200).${RESET}"
  else
    echo -e "${RED}Failed to visit $random_site (HTTP Status: $curl_output).${RESET}"
  fi

  # Random wait time between 0 and 30 seconds
  delay=$(( RANDOM % 31 ))
  echo -e "${BLUE}Waiting $delay seconds...${RESET}"
  sleep "$delay"
done
