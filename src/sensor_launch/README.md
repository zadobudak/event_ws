# Sensor Launch Package

A modular ROS launch system for managing multiple sensors with configurable parameters and different deployment scenarios.

## Architecture

This package follows a **modular launch architecture** with three levels:

### 1. Sensor-Specific Launch Files (`launch/sensors/`)
- **`realsense.launch`** - RealSense camera configuration
- **`velodyne.launch`** - Velodyne LiDAR configuration  
- **`xsens.launch`** - XSens IMU configuration
- **`nmea.launch`** - NMEA GPS configuration
- **`dvs.launch`** - DVS event camera configuration

Each sensor launch file:
- Defines configurable parameters using `<arg>` tags
- Loads sensor-specific parameter files from `config/`
- Sets up TF frames and transformations
- Can be launched independently for testing

### 2. Master Launch File (`launch/master/all_sensors.launch`)
- **Central configuration hub** that includes all sensor launch files
- Uses `<group if="$(arg enable_*)"` to conditionally enable sensors
- Configurable robot name, frame IDs, and output settings
- Loads robot description and sets up TF tree

### 3. Deployment-Specific Launch Files (`launch/master/`)
- **`development.launch`** - Minimal sensors for development (RealSense + RViz)
- **`production.launch`** - All sensors enabled for full operation
- **`all_sensors.launch`** - Base configuration that others extend

## Usage Examples

### Launch All Sensors (Production)
```bash
roslaunch sensor_launch production.launch
```

### Launch Development Configuration
```bash
roslaunch sensor_launch development.launch
```

### Launch Specific Sensor Only
```bash
roslaunch sensor_launch sensors/realsense.launch camera_name:=front_camera
```

### Custom Configuration
```bash
roslaunch sensor_launch all_sensors.launch enable_velodyne:=false robot_name:=test_robot
```

## Configuration

### Parameter Files (`config/`)
- **`realsense_params.yaml`** - RealSense camera settings
- **`velodyne_params.yaml`** - LiDAR configuration
- **`diagnostics.yaml`** - System health monitoring

### Customization
1. **Modify sensor parameters** in the respective YAML files
2. **Add new sensors** by creating new launch files in `launch/sensors/`
3. **Create new deployment profiles** by extending `all_sensors.launch`
4. **Adjust TF frames** in the sensor launch files

## Benefits of This Architecture

✅ **Modularity** - Each sensor is self-contained  
✅ **Reusability** - Launch files can be used independently  
✅ **Configurability** - Easy to enable/disable sensors  
✅ **Maintainability** - Clear separation of concerns  
✅ **Scalability** - Easy to add new sensors or configurations  
✅ **Testing** - Can test individual sensors in isolation  

## Adding New Sensors

1. Create sensor launch file in `launch/sensors/`
2. Add parameter file in `config/`
3. Update `all_sensors.launch` with new sensor group
4. Add enable/disable argument to master launch files

## Dependencies

- `realsense2_camera` - RealSense camera driver
- `velodyne_driver` - Velodyne LiDAR driver  
- `velodyne_pointcloud` - LiDAR point cloud conversion
- `xsens_driver` - XSens IMU driver
- `nmea_navsat_driver` - GPS driver
- `rpg_dvs` - DVS event camera driver
