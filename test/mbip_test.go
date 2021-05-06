package test

import (
	"os"
	"regexp"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/joho/godotenv"
	"github.com/stretchr/testify/assert"
	"gitswarm.f5net.com/bigiq-mgmt/mbiq-group/mbiq-system-team/mbiq-tools/go/vio/pkg/compute"
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
	client, err := compute.NewComputeClient(&compute.AuthInfo{
			AuthURL:     envVars[`TF_VAR_auth_url`],
			Username:    envVars[`TF_VAR_user_name`],
			Password:    envVars[`TF_VAR_password`],
			ProjectName: envVars[`TF_VAR_tenant_name`],
			DomainName:  `default`,
	})
	if err != nil {
		t.Fatalf("Failed to log in to VIO: %s", err)
	}

	t.Logf("Querying available MBIP images")
	images, err := client.GetMBIPImages()
	if err != nil {
		t.Fatalf("Failed to get list of MBIP images from VIO: %s", err)
	}
	if len(images) <= 0 {
		t.Fatal("No MBIP images found")
	}

	imageName := images[0].Name
	t.Logf("Running test using image %s", imageName)

	return imageName
}

func TestTerraformSingleMBIP(t *testing.T) {
	envVars := getEnvVars()
	envVars[`TF_VAR_num_mbips`] = `1`

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
