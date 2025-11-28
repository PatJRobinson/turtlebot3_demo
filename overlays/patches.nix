# overlays/patches.nix
self: super: {
  rosPackages =
    super.rosPackages
    // {
      kilted = super.rosPackages.kilted.overrideScope (rosSelf: rosSuper: {
        hls-lfcd-lds-driver = rosSuper.hls-lfcd-lds-driver.overrideAttrs (old: {
          postPatch =
            (old.postPatch or "")
            + ''
              echo ">>> APPLYING PATCH >>>"
              substituteInPlace src/hlds_laser_publisher.cpp \
                --replace "boost::asio::io_service" "boost::asio::io_context"
              substituteInPlace include/hls_lfcd_lds_driver/lfcd_laser.hpp \
                --replace "boost::asio::io_service" "boost::asio::io_context"
            '';
        });

        nav2-costmap-2d = rosSuper.nav2-costmap-2d.overrideAttrs (old: {
          NIX_CFLAGS_COMPILE =
            (old.NIX_CFLAGS_COMPILE or "") + " -Wno-error=array-bounds";
        });

        nav2-common = rosSuper.buildRosPackage {
          pname = "ros-kilted-nav2-common";
          version = "X.Y.Z-r1";

          src = super.fetchurl {
            url = "https://github.com/ros2-gbp/navigation2-release/archive/release/kilted/nav2_common/1.4.2-1.tar.gz";
            name = "nav2_common-1.4.2-1.tar.gz";
            sha256 = "sha256-8szZ2kByuSVobAiKvkh6ZP3k/hwBuDLdzC/YNNR2QtM=";
          };

          buildType = "ament_cmake";

          nativeBuildInputs = [rosSuper.ament-cmake-core];
          buildInputs = [rosSuper.ament-cmake-python];

          propagatedBuildInputs = [
            rosSuper.ament-cmake-core
            rosSuper.launch
            rosSuper.launch-ros
            rosSuper.osrf-pycommon
            rosSuper.python3Packages.pyyaml
            rosSuper.rclpy
          ];

          meta = {
            description = "Common support functionality used throughout Navigation2";
            license = with super.lib.licenses; [asl20];
          };
        };

        fastdds = rosSuper.fastdds.overrideAttrs (old: {
          cmakeFlags =
            (old.cmakeFlags or [])
            ++ [
              "-DSECURITY=ON"
            ];
        });

        "rmw-fastrtps-cpp" = rosSuper."rmw-fastrtps-cpp".overrideAttrs (old: {
          cmakeFlags =
            (old.cmakeFlags or [])
            ++ [
              "-DSECURITY=ON"
            ];
        });

        "rmw-fastrtps-dynamic-cpp" = rosSuper."rmw-fastrtps-dynamic-cpp".overrideAttrs (old: {
          cmakeFlags =
            (old.cmakeFlags or [])
            ++ [
              "-DSECURITY=ON"
            ];
        });

        "rmw-fastrtps-shared-cpp" = rosSuper."rmw-fastrtps-shared-cpp".overrideAttrs (old: {
          cmakeFlags =
            (old.cmakeFlags or [])
            ++ [
              "-DSECURITY=ON"
            ];
        });
      });
    };
}
