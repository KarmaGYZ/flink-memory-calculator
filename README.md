# flink-memory-calculator
A third party tool to simulate the calculation result of Flink's memory configuration.

  - calculator-1.10.sh for Flink-1.10.
  - calculator-1.11.sh for Flink-1.11.

Usage:
Add the `calculator-{1.10 or 1.11}.sh` to the `FLINK_DIST/bin`. You should set all configurations in your `FLINK_CONF_DIR` and then execute `bin/calculator-{1.10 or 1.11}.sh`. You could also append dynamic config options to it.

If you want to use "-tm", please repalce it with "-Dtaskmanager.memory.process.size=". This config would be deprecated eventually.

If successed, the result format should be:

```
JVM Parameters:
    -Xmx536870902
    -Xms536870902
    -XX:MaxDirectMemorySize=268435458
    -XX:MaxMetaspaceSize=100663296

TaskManager Dynamic Configs:
    taskmanager.memory.framework.off-heap.size=134217728b
    taskmanager.memory.network.max=134217730b
    taskmanager.memory.network.min=134217730b
    taskmanager.memory.framework.heap.size=134217728b
    taskmanager.memory.managed.size=536870920b
    taskmanager.cpu.cores=1.0
    taskmanager.memory.task.heap.size=402653174b
    taskmanager.memory.task.off-heap.size=0b
```

We also provide human-readable mode, you could switch to this mode by executing `bin/calculator-{1.10 or 1.11}.sh -h`. In this mode, all the memory size would be converted to a human-readable string. Note that there could be precision loss in converting. For the above sample, it would be:

```
JVM Parameters:
    -Xmx511mb
    -Xms511mb
    -XX:MaxDirectMemorySize=256mb
    -XX:MaxMetaspaceSize=96mb

TaskManager Dynamic Configs:
    taskmanager.memory.framework.off-heap.size=128mb
    taskmanager.memory.network.max=128mb
    taskmanager.memory.network.min=128mb
    taskmanager.memory.framework.heap.size=128mb
    taskmanager.memory.managed.size=512mb
    taskmanager.cpu.cores=1.0
    taskmanager.memory.task.heap.size=383mb
    taskmanager.memory.task.off-heap.size=0b
```
