// +build !windows,!plan9,!js

package shell

import (
	"os"
	"strconv"
	"sync"
	"testing"
	"time"

	"src.elv.sh/pkg/daemon"
	"src.elv.sh/pkg/daemon/client"
	"src.elv.sh/pkg/daemon/daemondefs"
	"src.elv.sh/pkg/eval"
	"src.elv.sh/pkg/testutil"

	. "src.elv.sh/pkg/prog/progtest"
)

func TestShell_ConnectsToDaemon(t *testing.T) {
	f := Setup()
	defer f.Cleanup()

	// Run the daemon in the same process for simplicity.
	var wg sync.WaitGroup
	wg.Add(1)
	defer wg.Wait()
	go func() {
		daemon.Serve("sock", "db")
		wg.Done()
	}()
	// Block until the socket file exists, so that Elvish will not try to spawn
	// again.
	hasSock := make(chan struct{})
	go func() {
		defer close(hasSock)
		for {
			_, err := os.Stat("sock")
			if err == nil {
				return
			}
			time.Sleep(time.Millisecond)
		}
	}()
	select {
	case <-hasSock:
	// Do nothing
	case <-time.After(testutil.ScaledMs(100)):
		t.Fatalf("timed out waiting for daemon to start")
	}

	f.FeedIn("use daemon; print $daemon:pid\n")
	Interact(f.Fds(),
		&InteractConfig{
			Evaler:         eval.NewEvaler(),
			ActivateDaemon: client.Activate,
			SpawnConfig:    &daemondefs.SpawnConfig{SockPath: "sock", DbPath: "db", RunDir: "."}})

	f.TestOut(t, 1, strconv.Itoa(os.Getpid()))
}
