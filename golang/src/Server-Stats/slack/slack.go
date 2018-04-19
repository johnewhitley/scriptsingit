package slack

import (
	"github.com/ashwanthkumar/slack-go-webhook"
	"fmt"
	"os"
	"strconv"
	"github.com/Server-Stats/cpuinfo"
	"time"
	"github.com/Server-Stats/serviceinfo"
	"strings"
	"github.com/Server-Stats/meminfo"
)

func FloatToString(input_num float64) string {
	// to convert a float number to a string
	return strconv.FormatFloat(input_num, 'f', 6, 64)
}

func Slack_post(diskstat map[string][]uint64, dirs []string, services []string) (error) {
	var color string
	var servicecolor string
	var memcolor string

	serverhostname, err := os.Hostname()
	if err != nil {
		return err
	}
	webhookUrl := "https://hooks.slack.com/services/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"

	idle0, total0 := cpuinfo.GetCPULoad()
	time.Sleep(3 * time.Second)
	idle1, total1 := cpuinfo.GetCPULoad()

	idleTicks := float64(idle1 - idle0)
	totalTicks := float64(total1 - total0)
	cpuUsage := 100 * (totalTicks - idleTicks) / totalTicks

	cpucolor := ""
	attachment1 := slack.Attachment{Color:&cpucolor}

	if cpuUsage >= 80 {
		cpucolor = "bad"
	} else if cpuUsage < 79 {
		cpucolor = "good"
	}

	attachment1.AddField(slack.Field{Title: "CPU Load on " + serverhostname}).AddField(slack.Field{Value: "CPU usage is " + FloatToString(cpuUsage) + "% [busy: " + FloatToString(totalTicks-idleTicks) + " total: " + FloatToString(totalTicks) +"]\n"})


	attachment2 := slack.Attachment{Color:&color}
	for _, i := range dirs {
		total := strconv.Itoa(int(diskstat[i][0])) + "GB"
		used := strconv.Itoa(int(diskstat[i][1])) + "GB"
		free := strconv.Itoa(int(diskstat[i][2])) + "GB"

		if i == "/opt" && int(diskstat[i][2]) <= 50 {
			color = "bad"
			attachment2.AddField(slack.Field{Title: "Space size of " + i + " on " + serverhostname}).AddField(slack.Field{Value: "Total Space: " + total + "\n" + "Used Space: " + used + "\n" + "Free Space: " + free + " <----Less than 50GB Free"})
		} else if i == "/opt" && int(diskstat[i][2]) > 50 {
			color = "good"
			attachment2.AddField(slack.Field{Title: "Space size of " + i + " on " + serverhostname}).AddField(slack.Field{Value: "Total Space: " + total + "\n" + "Used Space: " + used + "\n" + "Free Space: " + free})
		} else {
			color = "good"
			attachment2.AddField(slack.Field{Title: "Space size of " + i + " on " + serverhostname}).AddField(slack.Field{Value: "Total Space: " + total + "\n" + "Used Space: " + used + "\n" + "Free Space: " + free})
		}
	}

	attachment3 := slack.Attachment{Color:&servicecolor}
	var	goodservices map[string][]string
	var	badservices map[string][]string
	goodservices = make(map[string][]string)
	badservices = make(map[string][]string)
	for _, service := range services {
		running := serviceinfo.ValidateService(service)

		if strings.Compare(strings.TrimRight(running, "\n") , "active") != 0 {
			badservices["badservices"] = append(badservices["badservices"], service)
		} else if strings.Compare(strings.TrimRight(running, "\n"), "active") == 0 {
			goodservices["goodservices"] = append(goodservices["goodservices"], service)
		} else {
			fmt.Println("Could not validate if " + service + " is good or not")
			os.Exit(4)
		}
	}

	if len(badservices) > 0 {
		attachment3.AddField(slack.Field{Title: "Service Health on " + serverhostname}).AddField(slack.Field{Value: "Following Services are healthy: " + strings.Join(goodservices["goodservices"], ", ")}).AddField(slack.Field{Value: "Following Services are not healthy: " + strings.Join(badservices["badservices"], ", ")})
		servicecolor = "Bad"
	} else if len(badservices) == 0 {
		attachment3.AddField(slack.Field{Title: "Service Health on " + serverhostname}).AddField(slack.Field{Value: "Following Services are healthy: " + strings.Join(goodservices["goodservices"], ", ")})
		servicecolor = "good"
	}

	attachment4 := slack.Attachment{Color:&memcolor}
	avalmem, usedmem, percmem := meminfo.GetMemory()

	if percmem >= 80 {
		attachment4.AddField(slack.Field{Title: "Memory Usage on " + serverhostname}).AddField(slack.Field{Value: "Memory is high!!"}).AddField(slack.Field{Value: "Memory Usage is " + usedmem + "/" + avalmem + "MB (" + strconv.FormatFloat(percmem, 'f', 2, 64) + "%)"})
		memcolor = "bad"
	} else if percmem < 80 {
		attachment4.AddField(slack.Field{Title: "Memory Usage on " + serverhostname}).AddField(slack.Field{Value: "Memory Usage is " + usedmem + "/" + avalmem + "MB (" + strconv.FormatFloat(percmem, 'f', 2, 64) + "%)"})
		memcolor="good"
	}

	payload := slack.Payload {
		Text: serverhostname,
		Username: "webhookbot",
		Channel: "#server-stats",
		IconEmoji: ":ghost:",
		Attachments: []slack.Attachment{attachment1, attachment4, attachment2, attachment3},
	}

	posterr := slack.Send(webhookUrl, "", payload)
	if posterr != nil {
		fmt.Printf("error: %s\n", posterr)
	}
	return err
}