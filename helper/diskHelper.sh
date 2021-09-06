#!/bin/bash

function isDirectory() {
  [ -d "${1}" ]
}

function fileExists() {
  [ -f "${1}" ]
}