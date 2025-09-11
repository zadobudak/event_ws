# Sensor Launch Package

Basic ROS launch collection for starting sensors under a single robot namespace and recording their topics.

## Namespacing

- All sensors are launched under `/robot_name/...` using a top-level namespace in `launch/master/all_sensors.launch`.
- Each sensor also uses its own sub-namespace (e.g. `/robot/xsens`, `/robot/velodyne`, `/robot/gps`, `/robot/davis`).

## Start All Sensors

```bash
roslaunch sensor_launch all_sensors.launch  \
  enable_velodyne:=true enable_xsens:=true enable_nmea:=true enable_davis346:=true
```

Default arguments in `all_sensors.launch`:
- `robot_name`: top-level namespace (default: `robot`)
- `output`: node console output mode (`screen` or `log`)
- `enable_*`: enable/disable individual sensors

## Start Individual Sensors

```bash
# XSens IMU
roslaunch sensor_launch sensors/xsens.launch

# Velodyne LiDAR
roslaunch sensor_launch sensors/velodyne.launch

# NMEA GPS
roslaunch sensor_launch sensors/nmea_gps.launch

# DAVIS 346 event camera
roslaunch sensor_launch sensors/davis346.launch
```

## Recording

Record all topics under the robot namespace with timestamped bag files:

```bash
roslaunch sensor_launch record.launch 
```

Notes:
- Files are saved with date-time automatically by rosbag (e.g. `robot_YYYY-MM-DD-HH-MM-SS.bag`).
- Ensure `output_dir` exists and is writable.

## Parameter Files

Common configs are in `config/` (e.g. `velodyne_params.yaml`, `nmea_gps_params.yaml`).

## Dependencies

- `velodyne_driver`, `velodyne_pointcloud`
- `xsens_driver`
- `nmea_navsat_driver`
- `rpg_dvs`
- (optional) `realsense2_camera`
