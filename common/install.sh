#!/system/bin/sh
# iKCAL™ by Raiden Ishigami (raidenkkj @ GitHub).
# If you use parts of this project, please credit the respective authors.

# KCAL - Working Directory
# Check if the KCAL directory exists on the default path
if [[ -d "/sys/devices/platform/kcal_ctrl.0" ]]; then
  KCAL_DIR="/sys/devices/platform/kcal_ctrl.0"
  ALT_KCAL_DIR="0"

# Check if the KCAL directory exists on the alternate path
elif [[ -d "/sys/module/msm_drm/parameters" ]]; then
  KCAL_DIR="/sys/module/msm_drm/parameters"
  if [[ -f "$KCAL_DIR/kcal_red" ]] || [[ -f "$KCAL_DIR/kcal_green" ]] || [[ -f "$KCAL_DIR/kcal_blue" ]]; then
    KCAL_FILE="1"
  fi
    ALT_KCAL_DIR="1"
fi

# Variable to know if KCAL is active or deactivated
if [[ "$KCAL_TDIR" == "0" ]]; then
  KCALSTATUS="$(cat $KCAL_DIR/kcal_enable)"
fi

# Modpath
modpath="/data/adb/modules_update/iKCAL/"

# Function to store current KCAL settings
backup_preset() {
  # Source and destination directories
  src_dir="$KCAL_DIR"
  dst_dir="/data/local/perm_kcal_backup"

  # Create the destination directory if it doesn't exist
  [[ ! -d "$dst_dir" ]] && mkdir -p "$dst_dir"

  # Define the directories to be copied based on ALT_KCAL_DIR value
  if [[ "$ALT_KCAL_DIR" == "0" ]]; then
    preset_dirs="kcal kcal_min kcal_sat kcal_hue kcal_val kcal_cont"
  elif [[ "$ALT_KCAL_DIR" == "1" ]]; then
    preset_dirs="kcal_red kcal_green kcal_blue kcal_sat kcal_hue kcal_val kcal_cont"
  fi

  # Copy the relevant directories
  for dir in $preset_dirs; do
    cp -r "$src_dir/$dir" "$dst_dir"
  done

  # Message that signals the end of the backup
  sleep 1.5
  ui_print ""
  ui_print "[*] - Backup created!"
  ui_print ""
}

# Installation
awk '{print}' "${modpath}common/ikcal_banner"
sleep 0.5
ui_print "VERSION: $(grep_prop version "${modpath}module.prop") - $(grep_prop bdate "${modpath}module.prop")"
sleep 0.5
ui_print ""
ui_print "CODENAME: $(grep_prop codename "${modpath}module.prop")"
sleep 0.5
ui_print ""
ui_print "With this module you can choose handpicked KCAL presets."
sleep 1
ui_print ""
ui_print "[*] - Checking if your kernel supports KCAL..."
sleep 1.5
ui_print ""

# Check if KCAL is supported
if [[ -d "$KCAL_DIR" ]]; then
  if [[ "$ALT_KCAL_DIR" == "0" ]]; then
    ui_print "[*] - Your kernel supports KCAL, proceeding with installation..."
    sleep 1.5
  elif [[ "$ALT_KCAL_DIR" == "1" && -n "$KCAL_FILE" ]]; then
    ui_print "[*] - Your kernel supports KCAL, proceeding with installation..."
    sleep 1.5
  else
    ui_print "[*] - Your kernel supports KCAL, but the KCAL files are missing. Terminating installation..."
    sleep 1.5
    exit 1
  fi
elif [[ ! -d "$KCAL_DIR" ]]; then
  ui_print "[*] - Your kernel unfortunately does not support KCAL, terminating installation..."
  sleep 1.5
  exit 1
else
  ui_print "[*] - KCAL support status is unknown, terminating installation..."
  sleep 1.5
  exit 1
fi

# Check if KCAL is disabled and enable it
if [[ "$KCALSTATUS" == "1" ]]; then
  echo '0' > $KCAL_DIR/kcal_enable
fi

# KCAL settings backup
ui_print ""
ui_print "[*] - Creating backup of KCAL settings..."
backup_preset

# Download essential files for the module to work
ui_print "[*] - Downloading the latest script(s) from GitHub..."
wget -O "${modpath}system/bin/ikcal" "https://raw.githubusercontent.com/raidenkkj/iKCAL/main/system/bin/ikcal"
wget -O "${modpath}mod-util.sh" "https://raw.githubusercontent.com/raidenkkj/iKCAL/main/mod-util.sh"

# Finished installation
ui_print ""
ui_print "[*] - Done, thank you for choosing iKCAL!"
ui_print ""