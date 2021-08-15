#!/bin/bash

function dockerMain() {
  ##
  # Holds the full path of this script
  ##
  local -r scriptPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

  ##
  # Construct; Actions before starting the main flow of the script.
  ##
  function construct() {
    source "${scriptPath}/helper/output.sh"
  }

  function execute() {
    case ${2} in
    clean)
      outputInfo "... cleaning up all unused containers"
      docker container prune -f

      outputInfo "\n... cleaning up all unused images"
      docker image prune -a -f

      outputLine
      ;;
    help)
      outputUsage
      ;;
    *)
      outputUsage
      ;;
    esac
  }

  ##
  # Display usage/help text.
  ##
  function outputUsage() {
    outputInfo "\ndoc -d. A helper for docker commands."

    cat <<EOF
Usage: doc -d [command]
    help    This help text
    clean   Removes all images and containers, except if currently in-use

Example:
    $ doc -d clean

EOF

    exit 0
  }

  construct "$@"
  execute "$@"
}
