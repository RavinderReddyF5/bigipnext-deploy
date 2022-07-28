# [0.6.1](https://gitswarm.f5net.com/terraform/modules/openstack/mbip/-/compare/v0.6.0...v0.6.1) (2022-07-28)
- Add third interface for the HA data plane VLAN

# [0.6.0](https://gitswarm.f5net.com/terraform/modules/openstack/mbip/-/compare/v0.5.1...v0.6.0) (2022-07-22)
- Configure internal and external network self IPs by creating ports with fixed IPs

# [0.5.1](https://gitswarm.f5net.com/terraform/modules/openstack/mbip/-/compare/v0.5.0...v0.5.1) (2022-07-12)
- Set OS_AUTH_URL when getting the latest image from openstack

# [0.5.0](https://gitswarm.f5net.com/terraform/modules/openstack/mbip/-/compare/v0.4.0...v0.5.0) (2022-07-08)
- Update required terraform version to 1.2.4
- Update openstack provider version to 1.47.0
- Remove functionality for creating floating IP addresses
- Clean up variable names and descriptions

# [0.4.0](https://gitswarm.f5net.com/terraform/modules/openstack/mbip/-/compare/v0.3.2...v0.4.0) (2022-06-08)
- Add support for specifying the BIG-IP Next release to use when finding the latest image
- Upgrade to terraform-runner version 3.0.1 to get the new VIO client that fetches the new BIG-IP Next k3s images

# [0.3.2](https://gitswarm.f5net.com/terraform/modules/openstack/mbip/-/compare/v0.3.1...v0.3.2) (2022-04-06)
- Add Option to Create Cluster IP along with mBIP instances for HA

# [0.3.1](https://gitswarm.f5net.com/terraform/modules/openstack/mbip/-/compare/v0.3.0...v0.3.1) (2021-12-07)
- Add two additional network interfaces for internal and external networks

# [0.3.0](https://gitswarm.f5net.com/terraform/modules/openstack/mbip/-/compare/v0.2.0...v0.3.0) (2021-11-07)
- Update required terraform version to 1.0.7

# [0.2.0](https://gitswarm.f5net.com/terraform/modules/openstack/mbip/-/compare/v0.1.0...v0.2.0) (2021-05-17)
- Add support for specifying network port name in order to use fixed ip

# [0.1.0](https://gitswarm.f5net.com/terraform/modules/openstack/mbip/-/compare/v0.0.1...v0.1.0) (2021-05-05)
- Add support for specifying 'latest' instead of a specific image name

# 0.0.1 (2021-04-21)
- Initial terraform module to create MBIP instances in VIO
