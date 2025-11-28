{
  inputs = {
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nix-ros-overlay,
    ...
  }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "freeimage-3.18.0-unstable-2024-04-18"
        ];
      };
      overlays = [
        nix-ros-overlay.overlays.default
        (import ./overlays/patches.nix)
        (import ./overlays/colcon-mixin.nix)
      ];
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      name = "turtlebot3-kilted-shell";

      packages = with pkgs.rosPackages.kilted; [
        (
          with pkgs.rosPackages.kilted;
            buildEnv {
              paths = [
                ros-core
                ament-cmake-core
                python-cmake-module
                sros2
                turtlebot3
                turtlebot3-gazebo
                navigation2
                nav2-bringup
              ];
            }
        )

        pkgs.colcon
        pkgs.python3Packages.vcstools
        pkgs.python3Packages.argcomplete
        pkgs.tree
        pkgs.ccache
        pkgs.byobu
        pkgs.tmux
        pkgs.ncurses
        pkgs.glances
      ];

      shellHook = ''
        echo "ROS 2 kilted TurtleBot3 environment"

        export OVERLAY_WS=$PWD/overlay
        export TURTLEBOT3_MODEL=burger

        # Set gazebo model path for rolling TB3
        export GAZEBO_MODEL_PATH=$OVERLAY_WS/install/turtlebot3_gazebo/share/turtlebot3_gazebo/models:$GAZEBO_MODEL_PATH

        # ------------------------------------------------
        # Clone overlay and fetch repos
        # ------------------------------------------------
        if [ ! -d overlay/src ]; then
          echo "Fetching overlay.x repos…"
          mkdir -p overlay
          if [ -f overlay.repos ]; then
            cp overlay.repos overlay/
            (cd overlay && vcs import src < overlay.repos)
          else
            echo "❗ No overlay.repos file found."
          fi
        fi

        # Initialize colcon mixins (first time)
        if ! colcon mixin list > /dev/null 2>&1; then
          echo "📦 Setting up colcon mixin repository..."
          colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml
          colcon mixin update default
        fi

        # ------------------------------------------------
        # Build overlay once
        # ------------------------------------------------
        if [ ! -d overlay/install ]; then
          echo "Building overlay using colcon..."
          cd overlay
          colcon build --symlink-install --mixin release ccache
          cd -
        fi

        # Source resulting workspace
        if [ -f overlay/install/setup.bash ]; then
          source overlay/install/setup.bash
        fi

        # ------------------------------------------------
        # Generate SROS2 artifacts if missing
        # ------------------------------------------------
        if [ ! -d keystore ]; then
          echo "Creating SROS2 keystore…"
          ros2 security generate_artifacts -k keystore \
            -p policies/tb3_gazebo_policy.xml
        fi

        export ROS_SECURITY_ENABLE=true
        export ROS_SECURITY_STRATEGY=Enforce
        export ROS_SECURITY_KEYSTORE=$PWD/keystore

        echo "ROS 2 kilted shell ready."
      '';
    };
  };
}
