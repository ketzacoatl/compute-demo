## Intro to Running HA Services with Nomad


### Check status of all jobs sent to Nomad for execution

```
$ nomad status
ID             Type     Priority  Status   Submit Date
autoscaler     service  50        running  11/20/17 00:16:16 UTC
hashi-ui       service  50        running  12/01/17 01:41:19 UTC
haskell-lang   service  50        running  12/01/17 12:12:57 UTC
lb             service  50        running  12/01/17 11:36:02 UTC
node-exporter  system   50        running  11/30/17 19:35:03 UTC
prometheus     service  50        running  12/04/17 05:20:17 UTC
sysbench       batch    50        running  11/20/17 00:12:50 UTC
```

### Service Registration in Consul

We can also see a list of those services (running on nomad) that have registered
with Consul's Service Catalog:

```
$ sudo consul catalog services
autoscaler-ladder-agent
consul
consul-template
fabio
hashi-ui-server-hashi-ui
haskell-lang-web-http
lb-fabio-server
node-exporter
nomad-client
nomad-server
prometheus-prom-server
```


### Detail Status on a Specific Job

```
$ nomad status haskell-lang
ID            = haskell-lang
Name          = haskell-lang
Submit Date   = 12/01/17 12:12:57 UTC
Type          = service
Priority      = 50
Datacenters   = data-ops-eval.us-west-2
Status        = running
Periodic      = false
Parameterized = false

Summary
Task Group  Queued  Starting  Running  Failed  Complete  Lost
web         0       0         1        0       5         0

Allocations
ID        Node ID   Task Group  Version  Desired  Status   Created At
a5a6b94e  b2a95d6f  web         5        run      running  12/01/17 12:12:57 UTC
```

### Detail Status of a Task Allocation (alloc-status)

```
$ nomad alloc-status a5a6b94e
ID                  = a5a6b94e
Eval ID             = af472c59
Name                = haskell-lang.web[0]
Node ID             = b2a95d6f
Job ID              = haskell-lang
Job Version         = 5
Client Status       = running
Client Description  = <none>
Desired Status      = run
Desired Description = <none>
Created At          = 12/01/17 12:12:57 UTC

Task "http" is "running"
Task Resources
CPU        Memory          Disk     IOPS  Addresses
0/500 MHz  21 MiB/256 MiB  300 MiB  0     http: 10.23.21.162:24905

Task Events:
Started At     = 12/01/17 12:13:11 UTC
Finished At    = N/A
Total Restarts = 0
Last Restart   = N/A

Recent Events:
Time                   Type        Description
12/01/17 12:13:11 UTC  Started     Task started by client
12/01/17 12:13:05 UTC  Driver      Downloading image fpco/haskell-lang-ci:latest
12/01/17 12:13:05 UTC  Task Setup  Building Task Directory
12/01/17 12:13:05 UTC  Received    Task received by client
```


### Check logs for a Specific Task Allocation

A word of warning, there can be a lot of output in the logs, and by default nomad
will stream it all to you. Here is a quiet service that has been running idle for
a month or so:

```
$ nomad logs -stderr 1a58b7a2 | wc -l
347091
```

Nearly 350k lines in that log!

Take a peek at the latest logs:

```
$ nomad logs -stderr -tail 1a58b7a2
time="2018-01-09T12:52:41Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:52:51Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:53:01Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:53:11Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:53:21Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:53:31Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:53:41Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:53:51Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:54:01Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:54:11Z" level=info msg="Redirecting / to /nomad"
```

Watch logs in realtime:

```
$ nomad logs -stderr -tail -f 1a58b7a2
time="2018-01-09T12:53:51Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:54:01Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:54:11Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:54:21Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:54:31Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:54:41Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:54:51Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:55:01Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:55:11Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:55:21Z" level=info msg="Redirecting / to /nomad"
time="2018-01-09T12:55:31Z" level=info msg="Redirecting / to /nomad"
^C
```

Service startup:

```
$ nomad logs -stderr 1a58b7a2 | head
time="2017-12-01T01:41:23Z" level=info msg=-----------------------------------------------------------------------------
time="2017-12-01T01:41:23Z" level=info msg="|                             HASHI UI                                      |"
time="2017-12-01T01:41:23Z" level=info msg=-----------------------------------------------------------------------------
time="2017-12-01T01:41:23Z" level=info msg="| listen-address       : http://0.0.0.0:3000                                |"
time="2017-12-01T01:41:23Z" level=info msg="| server-certificate   :                                                    |"
time="2017-12-01T01:41:23Z" level=info msg="| server-key       \t  :                                                    |"
time="2017-12-01T01:41:23Z" level=info msg="| proxy-address   \t  :                                                    |"
time="2017-12-01T01:41:23Z" level=info msg="| log-level       \t  : info                                               |"
time="2017-12-01T01:41:23Z" level=info msg="| nomad-enable     \t  : true                                               |"
time="2017-12-01T01:41:23Z" level=info msg="| nomad-read-only      : No (Hashi-UI can change Nomad state)               |"
```


### List the Task Allocation's Local Filesystem

```
$ nomad fs 1a58b7a2
Mode        Size     Modified Time          Name
drwxrwxrwx  4.0 KiB  12/01/17 01:41:19 UTC  alloc/
drwxrwxrwx  4.0 KiB  12/01/17 01:41:23 UTC  hashi-ui/
```

```
$ nomad fs 1a58b7a2 alloc/logs
Mode        Size     Modified Time          Name
-rw-r--r--  10 MiB   12/16/17 11:38:39 UTC  hashi-ui.stderr.0
-rw-r--r--  10 MiB   01/03/18 01:49:15 UTC  hashi-ui.stderr.1
-rw-r--r--  3.7 MiB  01/09/18 12:58:51 UTC  hashi-ui.stderr.2
-rw-r--r--  0 B      12/01/17 01:41:23 UTC  hashi-ui.stdout.0
```


### List Servers in the Nomad Clusters

```
$ nomad server-members
Name                                        Address     Port  Status  Leader  Protocol  Build  Datacenter               Region
core-leaders-i-06fc73f21db04cf7c.us-west-2  10.23.21.4  4648  alive   true    2         0.7.0  data-ops-eval.us-west-2  us-west-2
```


### List Nodes in the Nomad Cluster

```
$ nomad node-status
ID        DC                       Name                         Class          Drain  Status
b023d591  data-ops-eval.us-west-2  fabio-i-0a6cfc1cbfbcb1a0c    load-balancer  false  ready
415a1280  data-ops-eval.us-west-2  manage-i-08fcb51bd1d1d4d89   manage         false  ready
b2a95d6f  data-ops-eval.us-west-2  workers-i-097cd89d37ca397ae  compute        false  ready
```


### Detail Review of a Specific Node in the Cluster

```
$ nomad node-status 415a1280
ID      = 415a1280
Name    = manage-i-08fcb51bd1d1d4d89
Class   = manage
DC      = data-ops-eval.us-west-2
Drain   = false
Status  = ready
Drivers = docker,exec,raw_exec
Uptime  = 952h47m27s

Allocated Resources
CPU            Memory           Disk            IOPS
1650/2400 MHz  1.4 GiB/2.0 GiB  1.2 GiB/27 GiB  0/0

Allocation Resource Utilization
CPU          Memory
35/2400 MHz  441 MiB/2.0 GiB

Host Resource Utilization
CPU          Memory           Disk
72/2400 MHz  876 MiB/2.0 GiB  2.6 GiB/29 GiB

Allocations
ID        Node ID   Task Group     Version  Desired  Status   Created At
12fcb66e  415a1280  prom           3        run      running  12/04/17 05:20:17 UTC
1a58b7a2  415a1280  server         2        run      running  12/01/17 01:41:19 UTC
32705adc  415a1280  node_exporter  8        run      running  11/30/17 20:00:56 UTC
e01839f6  415a1280  ladder         1        run      running  11/30/17 20:00:56 UTC
```

