CHECK_ROOT() {
  USER_ID=$(id -u)
  if [ $USER_ID -ne 0 ]; then
      echo You are not a root user
      echo -e "\e[33You should run this script as a root user or with sudo\["
      exit 1
  fi
}

CHECK_ROOT