# Linux Process Management with Bash

## Overview

A small Bash project that demonstrates how to start, stop, and monitor the process state of a simulated Linux service.

The project covers background execution, PID tracking, signal handling, and basic operational checks.

## Files

- `1.sh` — Starts and stops the service, verifies its PID, and reports the result.
- `sleep-workin.sh` — Runs the simulated service and cleans up its PID file and child process on termination.

## Features

- **Background execution** — Starts the service in the background and confirms startup.
- **PID validation** — Checks whether the recorded PID belongs to the expected service.
- **Duplicate prevention** — Uses file locks to prevent multiple service instances and serialize management commands.
- **Low CPU usage** — Uses `sleep` to wait between operations.
- **Signal handling** — Handles termination signals and cleans up runtime resources.
- **Stale PID handling** — Removes outdated PID files when the service lock is free.
- **Operational feedback** — Reports successful actions, invalid commands, and conditions requiring investigation.

## Requirements

- Linux with Bash and `/proc`
- GNU grep and coreutils
- `flock`, provided by util-linux

Run the scripts as the same regular user.

## Getting Started

Clone the repository:

```bash
git clone https://github.com/3ta17/bash-sleep-server.git
cd bash-sleep-server
```

Start the service:

```bash
bash 1.sh start
```

Stop the service:

```bash
bash 1.sh stop
```

The management script locates `sleep-workin.sh` in its own directory.

## Runtime Files

Runtime files are stored in:

```text
${XDG_STATE_HOME:-$HOME/.local/state}/bash-sleep-server
```

| File | Purpose |
| --- | --- |
| `service.pid` | Records the service PID |
| `service.log` | Captures service output and startup errors |
| `control.lock` | Serializes start and stop commands |
| `service.lock` | Prevents duplicate service instances |

Lock files remain after shutdown. Locks are released automatically when the owning process exits.

## Basic Verification

Check Bash syntax:

```bash
bash -n 1.sh sleep-workin.sh
```

Start the service and inspect its process:

```bash
bash 1.sh start

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/bash-sleep-server"
ps -p "$(cat "$state_dir/service.pid")" -o pid,ppid,%cpu,args
```

Running `start` again should report that the service is already running:

```bash
bash 1.sh start
```

Stop the service:

```bash
bash 1.sh stop
```

## Limitations

This is a learning project that simulates a local service. It does not provide a network listener, automatic restart, boot integration, or application health checks.

SIGKILL cannot trigger cleanup and may leave a stale PID file or a temporary sleeping child process. PID checks reduce accidental targeting, but a process can exit between verification and signaling.

For production service management, use a service manager such as systemd.
