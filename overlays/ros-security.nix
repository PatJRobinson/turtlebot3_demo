# overlays/ros-security.nix
self: super: {
  rosPackages =
    super.rosPackages
    // {
      kilted = super.rosPackages.kilted.overrideScope (rosSelf: rosSuper: {
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
