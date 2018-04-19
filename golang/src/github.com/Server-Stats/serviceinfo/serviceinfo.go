package serviceinfo

import (
	"os/exec"
	"fmt"
)

func ValidateService(service string) (string) {
	out, _ := exec.Command("bash", "-c", "systemctl is-active " + service).Output()

	stringout := fmt.Sprintf("%s", out)

	return stringout
}