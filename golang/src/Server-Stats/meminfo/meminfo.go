package meminfo

import (
	"github.com/shirou/gopsutil/mem"
	"strconv"
	"fmt"
)

const (
	B  = 1
	KB = 1024 * B
	MB = 1024 * KB
	GB = 1024 * MB
)

func GetMemory() (string, string, float64){
	vmStat, err := mem.VirtualMemory()
	if err != nil {
		fmt.Println(err)
	}

	totalmemory := strconv.FormatUint(vmStat.Total/uint64(MB), 10)
	activememory := strconv.FormatUint(vmStat.Used/uint64(MB), 10)
	//usedmemory := strconv.FormatFloat(vmStat.UsedPercent, 'f', 2, 64)
	usedmemory := vmStat.UsedPercent


	return totalmemory, activememory, usedmemory
}