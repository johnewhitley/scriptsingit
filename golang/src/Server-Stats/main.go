package main

import (
	kingpin "gopkg.in/alecthomas/kingpin.v2"

	"os"
	"fmt"

	"github.com/Server-Stats/diskinfo"
	"github.com/Server-Stats/slack"
)

var (
	//Set your kingpin help flags for app var
	app              = kingpin.New("server-stats", "Reports server statistics to slack").Author("Kyle Wooten")
	CheckDirectories = app.Flag("check-dir", "Directory to check storage on (Example: --check-dir=/root/test/). This flag is repeatable.").Envar("CHECK_DIR").Required().ExistingDirs()
	CheckServices = app.Flag("check-service", "Check that the service is running (Example: --check-service=<service>. This flag is repeatable.").Envar("CHECK_SERVICE").Strings()
	DisableSlackPost = app.Flag("disable-slack", "This will disable the post to slack post").Default("false").Bool()
	)


func main() {
	/// Parse kingpin app flags for --help option
    kingpin.MustParse(app.Parse(os.Args[1:]))

	var array = []uint64{}

	x := make(map[string][]uint64)
	for _, i := range *CheckDirectories {
		diskAll, diskUsed, diskFree := diskinfo.DiskInformation(i)
		array = append(array, diskAll, diskUsed, diskFree)

		x[i] = append(x["key"], diskAll, diskUsed, diskFree)
	}

	if ! *DisableSlackPost {
		err := slack.Slack_post(x, *CheckDirectories, *CheckServices)
		if err != nil {
			fmt.Println(err)
		}
	}
}