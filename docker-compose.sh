#!/bin/bash

function dockerComposeMain() {
  ##
  # Holds the full path of this script
  ##
  local -r scriptPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

  ##
  # Construct; Actions before starting the main flow of the script.
  ##
  function construct() {
    source "${scriptPath}/helper/output.sh"
    source "${scriptPath}/helper/diskHelper.sh"
  }

  ##
  # Execute docker-compose actions for given directory
  #
  # @param string
  ##
  function execute() {
    case ${2} in
    help)
      outputUsage
      ;;
    *)
      directoryActions "$@"
      ;;
    esac
  }

  ##
  # Execute docker-compose actions for given directory
  #
  # @param string "Directory or global action"
  # @param string "Directory action"
  ##
  function directoryActions() {
    local dockerPaths
    # shellcheck disable=SC2006
    dockerPaths=`readConfig "dockerDirectory"`

    local dockerDirectories
    dockerDirectories=$(echo "${dockerPaths}" | tr ";" "\n")
    directoryCheck "${dockerDirectories}"

    local parameters=[]
    read -ra parameters <<<"$@"
    unset "parameters[0]"

    # Check to see if global actions for -c can be done.
    globalActions "${parameters[1]}"

    local directory=${parameters[1]}
    unset "parameters[1]"

    # set workingPath based on directory parameter and matching Docker directory.
    local workingPath
    for dockerDirectory in ${dockerDirectories}
    do
        if isDirectory "${dockerDirectory}/${directory}"; then
          workingPath="${dockerDirectory}/${directory}"

          break;
        fi
    done
    validateWorkingPath "${workingPath}"

    local action=${parameters[2]}
    case ${action} in
      down)
        dockerSync "${workingPath}" "stop"
        dockerCompose "${workingPath}" "down"
      ;;
      up)
        dockerSync "${workingPath}" "start"
        dockerCompose "${workingPath}" "up -d"
      ;;
      sync-restart)
        dockerSync "${workingPath}" "stop"
        dockerSync "${workingPath}" "start"
      ;;
      sync-logs)
        dockerSync "${workingPath}" "logs"
      ;;
      build)
        outputInfo "... cleaning up all unused images"
        docker image prune -f

        outputInfo "... removing stopped service containers"
        dockerCompose "${workingPath}" "rm"

        outputInfo "... building containers"
        dockerCompose "${workingPath}" "build --no-cache"
      ;;
      destroy)
        outputAffirmation "This will destroy all containers and volumes!"
        read -rp ' ' reply
        if [[ ! ${reply} =~ ^[Yy]$ ]]; then
          # shellcheck disable=SC2128
          [[ "$0" == "$BASH_SOURCE" ]] && exit 1 || return 1
        fi

        dockerSync "${workingPath}" "stop"
        dockerSync "${workingPath}" "clean"

        dockerCompose "$workingPath" "down -v --remove-orphans"
      ;;
      engage)
        directoryActions "-c" "${directory}" build
        outputLine
        directoryActions "-c" "${directory}" up
      ;;
      stop)
        dockerSync "${workingPath}" "stop"
        dockerCompose "$workingPath" "stop"
      ;;
      start)
        dockerSync "${workingPath}" "start"
        dockerCompose "$workingPath" "start"
      ;;
      *)
        outputUsage
      ;;
    esac

    outputSuccess "\ndoc -c ${directory} ${action} = Done."
  }

  ##
  # Any global actions (instead of directory actions) can be put here.
  #
  # @param string "possible global action"
  ##
  function globalActions() {
    case ${1} in
      list)
        outputInfo "... listing all directories"

        for dockerDirectory in ${dockerDirectories}; do
          for dir in "${dockerDirectory}"/*/; do
            if [ ! -f "${dir}docker-compose.yml" ]; then continue; fi

            IFS='/' read -ra splitDir <<< "$dir"
            echo -e "- ${splitDir[${#splitDir[@]}-1]}"
          done
        done

        outputInfo "\nYou can use the above directories with: doc -c [directory] [action]"
        exit 0
      ;;
    esac
  }

  ##
  # docker-sync actions, if usable/configured
  #
  # @param string "docker-sync directory"
  # @param string "docker-sync command"
  ##
  function dockerSync() {
      cd "${1}" || return
      if [ -f "docker-sync.yml" ]; then docker-sync "${2}"; fi
      cd - >/dev/null || return
  }

  ##
  # docker-compose actions, if usable/configured
  #
  # @param string "docker-compose directory"
  # @param string "docker-compose command"
  ##
  function dockerCompose() {
      local projectDirParam="--project-directory ${1}"
      local configFileParam="-f ${1}/docker-compose.yml"

      # shellcheck disable=SC2086
      docker-compose ${projectDirParam} ${configFileParam} ${2}
  }

  ##
  # Read the config.ini configuration file.
  #
  # @param string
  ##
  function readConfig() {
    sed -n 's/.*'"${1}"' *= *\([^ ]*.*\)/\1/p' < "${scriptPath}/config.ini"
  }

  ##
  # Check if an array of directories exist.
  #
  # @param string
  ##
  function directoryCheck() {
      for directory in ${1}; do
          if ! isDirectory "${directory}"; then
            outputLine
            outputError "\"${directory}\" does not exist. Check your config.ini."

            exit 1;
          fi
      done
  }

  function validateWorkingPath() {
    if [ -z "${1}" ]; then
      outputLine
      outputError "No valid directory given."

      exit 1;
    fi
    if ! fileExists "${1}/docker-compose.yml"; then
      outputLine
      outputError "Not a valid Docker directory: \"${1}/docker-compose.yml\" does not exist."

      exit 1;
    fi
  }

  ##
  # Display usage/help text.
  ##
  function outputUsage() {
    outputInfo "\ndoc -c. A helper for running docker-compose scripts."

    cat <<EOF
Usage: doc -c [directory] [action]
    help                      This help text
    list                      List available docker directories
    [directory] up            Up a docker stack
    [directory] down          Down a docker stack
    [directory] sync-restart  Restart syncing
    [directory] build         Build images and containers
    [directory] destroy       Completely remove (volume) containers, images and sync data
    [directory] engage        Combine a 'build' and an 'up'
    [directory] stop          Stop a stack (put in sleep mode)
    [directory] start         Start a stack (after it was stopped)

Example:
    $ doc -c localdb up
    $ doc -c localdb down
    'localdb' points to a directory in your Docker development directory, configured in config.ini

EOF

    exit 0
  }

  construct "$@"
  execute "$@"
}
