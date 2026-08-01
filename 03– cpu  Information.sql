--Script 07 – cpu  Information 

SELECT 
    cpu_count,--Logical CPU
    scheduler_count,
    hyperthread_ratio,
    numa_node_count,
    socket_count,
    cores_per_socket
FROM sys.dm_os_sys_info;



--Logical CPU/2= core number

---core number/numa_node_count= numa per node


--numa per node>=maxdop  