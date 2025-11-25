# overlays/patches.nix
self: super: {
  rosPackages = super.rosPackages // {
    jazzy = super.rosPackages.jazzy.overrideScope (rosSelf: rosSuper: {

      hls-lfcd-lds-driver = rosSuper.hls-lfcd-lds-driver.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          echo ">>> APPLYING PATCH >>>"
          substituteInPlace src/hlds_laser_publisher.cpp \
            --replace "boost::asio::io_service" "boost::asio::io_context"
          substituteInPlace include/hls_lfcd_lds_driver/lfcd_laser.hpp \
            --replace "boost::asio::io_service" "boost::asio::io_context"
        '';
      });

    });
  };
}
