#! /bin/bash

# The Docker App Container's development entrypoint.
# This is a script used by the project's Docker development environment to
# install the app dependencies automatically upon runnning.
set -ex

: ${APP_PATH:="/home/node/app"}
: ${APP_TEMP_PATH:="$APP_PATH/tmp"}
: ${APP_SETUP_LOCK:="$APP_TEMP_PATH/setup.lock"}
: ${APP_SETUP_WAIT:="5"}

# Define the functions lock and unlock our app containers setup
# processes:
function lock_setup { mkdir -p $APP_TEMP_PATH && touch $APP_SETUP_LOCK; }
function unlock_setup { rm -rf $APP_SETUP_LOCK; }
function wait_setup { echo "Waiting for app setup to finish..."; sleep $APP_SETUP_WAIT; }

# Specify a default command, in case it wasn't issued:
if [ -z "$1" ]; then set -- ember server --environment=$EMBER_ENVIRONMENT --live-reload-port 35730 "$@"; fi

# Run the setup routine if the command is 'ember':
if [[ "$1" = "ember" ]]; then

  # 'Unlock' the setup process if the script exits prematurely:
  trap unlock_setup HUP INT QUIT KILL TERM EXIT

  # Wait until the setup 'lock' file no longer exists:
  while [ -f $APP_SETUP_LOCK ]; do wait_setup; done

  # 'Lock' the setup process, to prevent a race condition with
  # another container trying to install dependencies:
  lock_setup

  # Check or install npm/bower dependencies:
  check-dependencies || npm install ||

  # run bower install only if bower.json exist
  FILE=bower.json
  if test -f "$FILE"; then
      bower install
  fi

  # 'Unlock' the setup process:
  unlock_setup
fi

# Execute the given or default command:
exec "$@"
