# flink-memory-calculator
A third party tool to simulate the calculation result of Flink's memory configuration. Only valid for Flink-1.10.

Usage:
Add the `calculator.sh` to the `FLINK_DIST/bin`. Well set all configurations in your `FLINK_CONF_DIR` and then execute `bin/calculator.sh`.

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
