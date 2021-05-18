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
	envVarNames = []string{
		`TF_VAR_auth_url`,
		`TF_VAR_admin_network_name`,
		`TF_VAR_mbip_name_prefix`,
		`TF_VAR_mbip_image_name`,
		`TF_VAR_mbip_flavor_name`,
		`TF_VAR_num_mbips`,
		`TF_VAR_tenant_name`,
		`TF_VAR_user_name`,
		`TF_VAR_password`,
		`TF_VAR_network_port_name`,
		`TF_VAR_network_port_ip`,
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
	t.Logf("Logging in to VIO")

	clientFactory := &client.DefaultFactory{}

	clientFactory.SetAuthInfo(&client.AuthInfo{
		AuthURL:     envVars[`TF_VAR_auth_url`],
		Username:    envVars[`TF_VAR_user_name`],
		Password:    envVars[`TF_VAR_password`],
		ProjectName: envVars[`TF_VAR_tenant_name`],
		DomainName:  `default`,
	})

	imageManager, err := clientFactory.CreateImageManager()

	if err != nil {
		t.Fatalf("Failed to log in to VIO: %s", err)
	}

	t.Logf("Querying available MBIP images")

	mbipImages, err := imageManager.GetAllImages(&image.ListOpts{
		Regex:          image.MBIPRegex,
		VersionFunc:    image.MBIPVersion,
		VersionSortDir: `asc`,
	})

	if err != nil {
		t.Fatalf("Failed to get list of MBIP images from VIO: %s", err)
	}

	if len(mbipImages) <= 0 {
		t.Fatal("No MBIP images found")
	}

	mbipImageName := mbipImages[0].Name
	t.Logf("Running test using image %s", mbipImageName)

	return mbipImageName
}

func TestTerraformSingleMBIP(t *testing.T) {
	envVars := getEnvVars()
	envVars[`TF_VAR_num_mbips`] = `1`
	envVars[`TF_VAR_network_port_name`] = `[]`

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		EnvVars:      envVars,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	ips := terraform.OutputList(t, terraformOptions, "admin_ipv4_addresses")
	assert.Len(t, ips, 1)
	assert.Regexp(t, ipRegexp, ips[0])
}

func TestTerraformMultipleMBIP(t *testing.T) {
	envVars := getEnvVars()
	envVars[`TF_VAR_num_mbips`] = `2`
	envVars[`TF_VAR_network_port_name`] = `[]`

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
}

func TestTerraformSpecificMBIPImage(t *testing.T) {
	envVars := getEnvVars()
	envVars[`TF_VAR_mbip_image_name`] = getOldestImage(t, envVars)
	envVars[`TF_VAR_network_port_name`] = `[]`

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		EnvVars:      envVars,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	ips := terraform.OutputList(t, terraformOptions, "admin_ipv4_addresses")
	assert.Len(t, ips, 1)
	assert.Regexp(t, ipRegexp, ips[0])
}

func TestTerraformFixedIpMBIP(t *testing.T) {
	envVars := getEnvVars()
	port_ips := strings.Split(envVars[`TF_VAR_network_port_ip`], ",")

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		EnvVars:      envVars,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	ips := terraform.OutputList(t, terraformOptions, "admin_ipv4_addresses")
	assert.Len(t, ips, 1)
	assert.Equal(t, port_ips[0], ips[0])
}
