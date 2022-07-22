package test

import (
	"os"
	"regexp"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/joho/godotenv"
	"github.com/stretchr/testify/assert"
	"gitswarm.f5net.com/bigiq-mgmt/mbiq-group/mbiq-system-team/mbiq-tools/go/vio/pkg/client"
	"gitswarm.f5net.com/bigiq-mgmt/mbiq-group/mbiq-system-team/mbiq-tools/go/vio/pkg/image"
)

var (
	ipRegexp    = regexp.MustCompile(`\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}`)
	selfIpRegex = regexp.MustCompile(`(\d+\.?){4}`)
	envVarNames = []string{
		`TF_VAR_auth_url`,
		`TF_VAR_username`,
		`TF_VAR_password`,
		`TF_VAR_tenant_name`,
		`TF_VAR_mbip_flavor_name`,
		`TF_VAR_admin_network_name`,
		`TF_VAR_network_port_names`,
		`TF_VAR_network_port_ips`,
		`TF_VAR_internal_network_name`,
		`TF_VAR_internal_network_subnet_name`,
		`TF_VAR_internal_ip_addresses`,
		`TF_VAR_external_network_name`,
		`TF_VAR_external_network_subnet_name`,
		`TF_VAR_external_ip_addresses`,
		`TF_VAR_mbip_name_prefix`,
		`TF_VAR_mbip_image_name`,
		`TF_VAR_mbip_release`,
		`TF_VAR_num_mbips`,
	}
)

func getEnvVars() map[string]string {
	envVars, err := godotenv.Read()
	if err != nil {
		envVars = make(map[string]string)
		for _, envVarName := range envVarNames {
			envVars[envVarName] = os.Getenv(envVarName)
		}
	}

	return envVars
}

func getOldestImage(t *testing.T, envVars map[string]string) string {
	t.Logf("Logging in to openstack")

	clientFactory := &client.DefaultFactory{}

	clientFactory.SetAuthInfo(&client.AuthInfo{
		AuthURL:     envVars[`TF_VAR_auth_url`],
		Username:    envVars[`TF_VAR_username`],
		Password:    envVars[`TF_VAR_password`],
		ProjectName: envVars[`TF_VAR_tenant_name`],
		DomainName:  `default`,
	})

	imageManager, err := clientFactory.CreateImageManager()

	if err != nil {
		t.Fatalf("Failed to log in to openstack: %s", err)
	}

	t.Logf("Querying available BIG-IP Next images for the 0.7.0 release")

	image.UpdateRegexesForRelease("0.7.0")
	mbipImages, err := imageManager.GetAllImages(&image.ListOpts{
		Regex:          image.MBIPRegex,
		VersionFunc:    image.MBIPVersion,
		VersionSortDir: `asc`,
	})

	if err != nil {
		t.Fatalf("Failed to get list of BIG-IP Next images from openstack: %s", err)
	}

	if len(mbipImages) <= 0 {
		t.Fatal("No BIG-IP Next images found")
	}

	mbipImageName := mbipImages[0].Name
	t.Logf("Running test using image %s", mbipImageName)

	return mbipImageName
}

func TestTerraformSingleMBIP(t *testing.T) {
	envVars := getEnvVars()
	envVars[`TF_VAR_num_mbips`] = `1`
	envVars[`TF_VAR_network_port_names`] = `[]`
	expectedInternalIp := selfIpRegex.FindAllString(envVars[`TF_VAR_internal_ip_addresses`], -1)[0]
	expectedExternalIp := selfIpRegex.FindAllString(envVars[`TF_VAR_external_ip_addresses`], -1)[0]

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		EnvVars:      envVars,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	ips := terraform.OutputList(t, terraformOptions, "admin_ipv4_addresses")
	assert.Len(t, ips, 1)
	assert.Regexp(t, ipRegexp, ips[0])

	internalIps := terraform.OutputList(t, terraformOptions, "internal_ipv4_addresses")
	assert.Len(t, internalIps, 1)
	assert.Regexp(t, ipRegexp, internalIps[0])
	assert.Equal(t, expectedInternalIp, internalIps[0])

	externalIps := terraform.OutputList(t, terraformOptions, "external_ipv4_addresses")
	assert.Len(t, externalIps, 1)
	assert.Regexp(t, ipRegexp, externalIps[0])
	assert.Equal(t, expectedExternalIp, externalIps[0])
}

func TestTerraformMultipleMBIP(t *testing.T) {
	envVars := getEnvVars()
	envVars[`TF_VAR_num_mbips`] = `2`
	envVars[`TF_VAR_network_port_names`] = `[]`
	envVars[`TF_VAR_internal_ip_addresses`] = `["10.1.255.1", "10.1.255.2"]`
	envVars[`TF_VAR_external_ip_addresses`] = `["10.2.255.1", "10.2.255.2"]`
	expectedInternalIps := selfIpRegex.FindAllString(envVars[`TF_VAR_internal_ip_addresses`], -1)
	expectedExternalIps := selfIpRegex.FindAllString(envVars[`TF_VAR_external_ip_addresses`], -1)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		EnvVars:      envVars,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	ips := terraform.OutputList(t, terraformOptions, "admin_ipv4_addresses")
	assert.Len(t, ips, 2)
	for _, ip := range ips {
		assert.Regexp(t, ipRegexp, ip)
	}

	internalIps := terraform.OutputList(t, terraformOptions, "internal_ipv4_addresses")
	assert.Len(t, internalIps, 2)
	for i, internalIp := range internalIps {
		assert.Regexp(t, ipRegexp, internalIp)
		assert.Equal(t, expectedInternalIps[i], internalIp)
	}

	externalIps := terraform.OutputList(t, terraformOptions, "external_ipv4_addresses")
	assert.Len(t, externalIps, 2)
	for i, externalIp := range externalIps {
		assert.Regexp(t, ipRegexp, externalIp)
		assert.Equal(t, expectedExternalIps[i], externalIp)
	}
}

func TestTerraformSpecificMBIPImage(t *testing.T) {
	envVars := getEnvVars()
	envVars[`TF_VAR_mbip_image_name`] = getOldestImage(t, envVars)
	envVars[`TF_VAR_network_port_names`] = `[]`
	expectedInternalIp := selfIpRegex.FindAllString(envVars[`TF_VAR_internal_ip_addresses`], -1)[0]
	expectedExternalIp := selfIpRegex.FindAllString(envVars[`TF_VAR_external_ip_addresses`], -1)[0]

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		EnvVars:      envVars,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	ips := terraform.OutputList(t, terraformOptions, "admin_ipv4_addresses")
	assert.Len(t, ips, 1)
	assert.Regexp(t, ipRegexp, ips[0])

	internalIps := terraform.OutputList(t, terraformOptions, "internal_ipv4_addresses")
	assert.Len(t, internalIps, 1)
	assert.Regexp(t, ipRegexp, internalIps[0])
	assert.Equal(t, expectedInternalIp, internalIps[0])

	externalIps := terraform.OutputList(t, terraformOptions, "external_ipv4_addresses")
	assert.Len(t, externalIps, 1)
	assert.Regexp(t, ipRegexp, externalIps[0])
	assert.Equal(t, expectedExternalIp, externalIps[0])
}

func TestTerraformFixedIpMBIP(t *testing.T) {
	envVars := getEnvVars()
	portIps := strings.Split(envVars[`TF_VAR_network_port_ips`], ",")
	expectedInternalIp := selfIpRegex.FindAllString(envVars[`TF_VAR_internal_ip_addresses`], -1)[0]
	expectedExternalIp := selfIpRegex.FindAllString(envVars[`TF_VAR_external_ip_addresses`], -1)[0]

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		EnvVars:      envVars,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	ips := terraform.OutputList(t, terraformOptions, "admin_ipv4_addresses")
	assert.Len(t, ips, 1)
	assert.Equal(t, portIps[0], ips[0])

	internalIps := terraform.OutputList(t, terraformOptions, "internal_ipv4_addresses")
	assert.Len(t, internalIps, 1)
	assert.Regexp(t, ipRegexp, internalIps[0])
	assert.Equal(t, expectedInternalIp, internalIps[0])

	externalIps := terraform.OutputList(t, terraformOptions, "external_ipv4_addresses")
	assert.Len(t, externalIps, 1)
	assert.Regexp(t, ipRegexp, externalIps[0])
	assert.Equal(t, expectedExternalIp, externalIps[0])
}
