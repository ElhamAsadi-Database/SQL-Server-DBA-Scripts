--1. شاخص‌های تشخیص Query طولانی
--برای تشخیص Query طولانی معمولاً این ستون‌ها بررسی می‌شوند:

--total_elapsed_time → مدت زمان اجرای Query
--cpu_time → مصرف CPU
--logical_reads / reads → میزان I/O
--wait_type → اگر Query در انتظار منابع باشد
--blocking_session_id → اگر Query توسط Query دیگر بلاک شده باشد

--total_elapsed_time
--که زمان اجرای Query را بر حسب میلی‌ثانیه نشان می‌دهد.


--dm_exec_requests → اطلاعات Query در حال اجرا
--dm_exec_sessions → اطلاعات Session
--dm_exec_sql_text → متن Query


SELECT
    r.session_id,
    s.login_name,
    s.host_name,
    r.status,
    r.start_time,
    r.cpu_time,
    r.total_elapsed_time / 1000 AS elapsed_seconds,
    r.logical_reads,
    r.reads,
    r.writes,
    r.wait_type,
    r.blocking_session_id,
    t.text AS query_text
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s
    ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.total_elapsed_time > 5000
ORDER BY r.total_elapsed_time DESC;


--این Query موارد زیر را نشان می‌دهد:

--Session اجرا کننده Query
--مدت اجرای Query
--CPU مصرف شده
--نوع Wait
--Blocking
--متن کامل Query


-- کویری که اجراش بیشتر از یک دقیقه طول کشیده
SELECT
    r.session_id,
    s.login_name,
    s.host_name,
    r.status,
    r.start_time,
    r.cpu_time,
    r.total_elapsed_time / 1000 AS elapsed_seconds,
	r.total_elapsed_time / 60000 AS elapsed_minutes,

    r.logical_reads,
    r.reads,
    r.writes,
    r.wait_type,
    r.blocking_session_id,
    t.text AS query_text
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s
    ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.total_elapsed_time > 60000
--WHERE r.cpu_time > 10000
--WHERE r.blocking_session_id <> 0 کویری ایی که بلاکینگ ایجاد کرده 
ORDER BY r.total_elapsed_time DESC;--;کویری طولانی
--ORDER BY r.cpu_time DESC سی پی یو زیاد مصرف میکنه

--WHERE r.total_elapsed_time > 300000 بیشتر از 5 دقیقه

----9. ابزارهای دیگر برای تشخیص Query طولانی
--علاوه بر DMVها می‌توان از این ابزارها استفاده کرد:

--Query Store
--Extended Events
--Activity Monitor
--sys.dm_exec_query_stats (برای Queryهای قبلاً اجرا شده)