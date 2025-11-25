# overlays/ros-security.nix
self: super: {
  rosPackages = super.rosPackages // {
    kilted = super.rosPackages.kilted.overrideScope (rosSelf: rosSuper: {

      fastdds = rosSuper.fastdds.overrideAttrs (old: {
        cmakeFlags = (old.cmakeFlags or []) ++ [
          "-DSECURITY=ON"
        ];
      });

      rmw_fastrtps_cpp = rosSuper.rmw_fastrtps_cpp.overrideAttrs (old: {
        cmakeFlags = (old.cmakeFlags or []) ++ [
          "-DSECURITY=ON"
        ];
      });

      rmw_fastrtps_dynamic_cpp = rosSuper.rmw_fastrtps_dynamic_cpp.overrideAttrs (old: {
        cmakeFlags = (old.cmakeFlags or []) ++ [
          "-DSECURITY=ON"
        ];
      });

      rmw_fastrtps_shared_cpp = rosSuper.rmw_fastrtps_shared_cpp.overrideAttrs (old: {
        cmakeFlags = (old.cmakeFlags or []) ++ [
          "-DSECURITY=ON"
        ];
      });

    });
  };
}
