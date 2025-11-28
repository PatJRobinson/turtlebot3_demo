#!/usr/bin/env bash

# Start a new tmux session named "secure"
tmux new-session -d -s secure -n diagnostic

# --- Diagnostic window ---
tmux send-keys -t secure:diagnostic 'glances' C-m

# --- Turtlebot window ---
tmux new-window -t secure -n turtlebot
tmux send-keys  -t secure:turtlebot 'export ROS_SECURITY_ENCLAVE_OVERRIDE=/gazebo' C-m
tmux send-keys  -t secure:turtlebot 'ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py' C-m

# Split horizontally for teleop
tmux split-window -h -t secure:turtlebot
tmux send-keys  -t secure:turtlebot.right 'export ROS_SECURITY_ENCLAVE_OVERRIDE=/teleop' C-m
tmux send-keys  -t secure:turtlebot.right 'ros2 run turtlebot3_teleop teleop_keyboard' C-m

# Split vertically for cmd_vel echo
tmux split-window -v -t secure:turtlebot.right
tmux send-keys  -t secure:turtlebot.down 'ros2 topic echo /cmd_vel' C-m

# Select teleop pane
tmux select-pane -t secure:turtlebot.1

# --- Navigation window ---
tmux new-window -t secure -n navigation
tmux send-keys  -t secure:navigation 'export ROS_SECURITY_ENCLAVE_OVERRIDE=/nav2_map' C-m
tmux send-keys  -t secure:navigation 'ros2 launch nav2_bringup tb3_simulation_launch.py use_simulator:=False' C-m

# split horizontally for initial_pose
tmux split-window -h -t secure:navigation
tmux send-keys -t secure:navigation.right 'configs/initial_pose.sh' C-m

# split vertically for navigate_to_pose
tmux split-window -v -t secure:navigation.right
tmux send-keys -t secure:navigation.down 'configs/navigate_to_pose.sh' C-m

# select initial_pose pane
tmux select-pane -t secure:navigation.1

# --- Mapping window ---
tmux new-window -t secure -n mapping
tmux send-keys -t secure:mapping 'export ROS_SECURITY_ENCLAVE_OVERRIDE=/nav2_slam' C-m
tmux send-keys -t secure:mapping 'ros2 launch nav2_bringup tb3_simulation_launch.py use_simulator:=False slam:=True' C-m

tmux split-window -h -t secure:mapping
tmux send-keys -t secure:mapping.right 'mkdir -p maps' C-m
tmux send-keys -t secure:mapping.right 'ros2 run nav2_map_server map_saver_cli -f maps/my_map' C-m

tmux split-window -v -t secure:mapping.right
tmux send-keys -t secure:mapping.down 'ros2 topic info -v /map' C-m

# select slam_toolbox pane (first pane)
tmux select-pane -t secure:mapping.0

# --- SROS window ---
tmux new-window -t secure -n sros
tmux send-keys -t secure:sros 'tree keystore -d' C-m

tmux split-window -h -t secure:sros
tmux send-keys -t secure:sros.right 'ros2 security generate_artifacts -k keystore -p policies/tb3_gazebo_policy.xml -e /' C-m

tmux split-window -v -t secure:sros.right
tmux send-keys -t secure:sros.down 'env | grep ROS' C-m

# --- RQT window ---
tmux new-window -t secure -n rqt
tmux send-keys -t secure:rqt 'export ROS_SECURITY_ENCLAVE_OVERRIDE=/' C-m
tmux send-keys -t secure:rqt 'rqt' C-m

# Reselect turtlebot window
tmux select-window -t secure:turtlebot

# Attach to the session
tmux attach-session -t secure

