#!/system/bin/sh
# iKCAL™ by Raiden Ishigami (raidenkkj @ GitHub).
# If you use parts of this project, please credit the respective authors.

# KCAL working directory
# Check if the kcal directory exists on the default path
if [[ -d "/sys/devices/platform/kcal_ctrl.0" ]]; then
    KCAL_DIR="/sys/devices/platform/kcal_ctrl.0"
    KCAL_TDIR="0"
# Check if the kcal directory exists on the alternate path
elif [[ -d "/sys/module/msm_drm/parameters" ]]; then
    KCAL_DIR="/sys/module/msm_drm/parameters"
    KCAL_TDIR="1"
else
    true
fi

# Variable to know if kcal is active or deactivated
if [[ "$KCAL_TDIR" == "0" ]]; then
  KCALSTATUS="$(cat $KCAL_DIR/kcal_enable)"
fi

# Modpath
modpath="/data/adb/modules_update/iKCAL/"

# Function to store current kcal data
backup_preset() {
  # Source and destination directories
  src_dir="$KCAL_DIR"
  dst_dir="/data/local/perm_kcal_backup"

  # Create the destination directory if it doesn't exist
  if [[ ! -d "$dst_dir" ]]; then
    mkdir -p "$dst_dir"
  fi

  # Copy the files from the source to the destination directory
  if [[ "$KCAL_TDIR" == "0" ]]; then
    cp -r "$src_dir"/kcal "$dst_dir"
    cp -r "$src_dir"/kcal_min "$dst_dir"
    cp -r "$src_dir"/kcal_sat "$dst_dir"
    cp -r "$src_dir"/kcal_hue "$dst_dir"
    cp -r "$src_dir"/kcal_val "$dst_dir"
    cp -r "$src_dir"/kcal_cont "$dst_dir"
  elif [[ "$KCAL_TDIR" == "1" ]]; then
    cp -r "$src_dir"/kcal_red "$dst_dir"
    cp -r "$src_dir"/kcal_green "$dst_dir"
    cp -r "$src_dir"/kcal_blue "$dst_dir"
    cp -r "$src_dir"/kcal_sat "$dst_dir"
    cp -r "$src_dir"/kcal_hue "$dst_dir"
    cp -r "$src_dir"/kcal_val "$dst_dir"
    cp -r "$src_dir"/kcal_cont "$dst_dir"
  fi

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
ui_print "With this module you can choose handpicked kcal presets."
sleep 1
ui_print ""
ui_print "[*] - Checking if your kernel supports KCAL..."
sleep 1.5
ui_print ""

# Check if kcal is supported
if [[ -d "$KCAL_DIR" ]]; then
  ui_print "[*] - Your kernel supports KCAL, proceeding with installation..."
  sleep 1.5
elif [[ ! -d "$KCAL_DIR" ]]; then
  ui_print "[*] - Your kernel unfortunately does not support KCAL, terminating installation..."
  sleep 1.5
  exit 1
else
  ui_print "[*] - KCAL support status is unknown, terminating installation..."
  sleep 1.5
  exit 1
fi

# Check if kcal is disabled and enable it
if [[ "$KCALSTATUS" == "1" ]]; then
  echo '0' > $KCAL_DIR/kcal_enable
fi

# Kcal data backup
ui_print ""
ui_print "[*] - Creating backup of kcal settings..."
backup_preset

# Download essential files for the module to work
ui_print "[*] - Downloading the latest script(s) from GitHub..."
wget -O "${modpath}system/bin/ikcal" "https://raw.githubusercontent.com/raidenkkj/iKCAL/main/system/bin/ikcal"
wget -O "${modpath}mod-util.sh" "https://raw.githubusercontent.com/raidenkkj/iKCAL/main/mod-util.sh"

# Finished installation
ui_print ""
ui_print "[*] - Done, thank you for choosing iKCAL!"
ui_print ""