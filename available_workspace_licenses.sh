# This script uses GAM to check on current G-Suite Enterprise License usage and will alert via Slack Webhook if the count is under the set threshold
# I am personally running this script via a LaunchDaemon every so often so I don't have to keep a close eye on licensing.

#!/bin/bash
# Sets GAM Path shortcut to default location.  Will want to change this to an exact location if running via a service
gam="$HOME/bin/gam/gam"
# Add your Slack Incoming Webhook URL Below
slack_webhook_url="https://hooks.slack.com/services/..."
# Set threshold to send slack notifications if less then this
license_threshold="5"
# Set Workspace Edition.  See: https://github.com/taers232c/GAMADV-XTD3/wiki/Reseller#definitions 
workspace_edition="workspaceenterprisestandard"
customer_domain="google.com"

# End of settings that need configured

echo "License threshold set to" $license_threshold". Slack notification will be sent if available licenses is less than this."
# Find license count and user count for licenses specified.  Use 'numberOfSeats:' for commitments & 'maximumNumberOfSeats:' for flex licenses.
license_count=$($gam info resoldsubscriptions $customer_domain $workspace_edition | grep 'numberOfSeats:' | tr -cd '0-9')
user_count=$($gam info resoldsubscriptions $customer_domain $workspace_edition | grep 'licensedNumberOfSeats:' | tr -cd '0-9')

# Calculate and display available G Suite user licenses, then store in variable
available_licenses=$(expr $license_count - $user_count)
echo $available_licenses "Google $workspace_edition Licenses Available"

if [ $available_licenses -lt $license_threshold ] 
then
    curl -X POST -H 'Content-type: application/json' --data "$(eval "echo "'{\"text\": \"$available_licenses Google $workspace_edition Licenses Available\"}'"")" $slack_webhook_url
else
    echo $available_licenses "Available licenses exceeds the set threshold of" $license_threshold". No Slack notification will be sent"
fi
