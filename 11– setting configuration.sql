

---Script 06 – setting configuration

---Memory Configuration
--Total RAM =64GB
 ---OS=8 GB 
 --Max Server Memory = Total RAM – OS Reserved
 --Max Server Memory = 56000 MB
 --Min Server Memory=10000 MB



 EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'min server memory (MB)', 10000;   -- 10GB
EXEC sp_configure 'max server memory (MB)', 56000;   -- 56GB
RECONFIGURE;

--main server--min =16000


 ---Parallelism Configuration 

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'cost threshold for parallelism', 50;--OLTP---Report transfer to replica secondary 
RECONFIGURE;
--50-75


-- بعذ از محاسبه و بررسی  numa node 
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'max degree of parallelism', 2;
RECONFIGURE;