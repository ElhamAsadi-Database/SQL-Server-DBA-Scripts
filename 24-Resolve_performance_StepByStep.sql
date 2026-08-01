
---اگر مشکل Performance داشته باشی:

--1: ابتدا Blocking را بررسی کن
--2:سپس Top CPU Queries
--3:بعد Top IO Queries
--4: بعد Memory Grants Waiting
--5: در نهایت TempDB Usage

--گام 1: بررسی Blocking
--هدف: آیا Sessionی وجود دارد که دیگران را Block کند؟

SELECT
    r.session_id,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time,
    r.status,
    r.command,
    t.text AS query_text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.blocking_session_id <> 0
ORDER BY r.blocking_session_id;

--معیارهای مهم
--blocking_session_id
--wait_type
--wait_time

--اگر مشکل وجود داشت، راه‌حل:
--Session مسدودکننده را شناسایی کن.
--Query مسدودکننده را بررسی کن:
--آیا مدت زیادی باز مانده؟
--. مهم‌ترین معیارها این‌ها هستند:


--total_elapsed_time
--open_transaction_count
SELECT
    r.session_id,
    r.blocking_session_id,
    r.status,
    r.start_time,
    r.total_elapsed_time / 1000 AS elapsed_seconds,
    r.wait_type,
    t.text AS query_text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
ORDER BY r.total_elapsed_time DESC;
--تحلیل:

--اگر مقدار elapsed_seconds مثلاً:

--چند ثانیه → طبیعی
--چند دقیقه → نیاز به بررسی
--چند ساعت → احتمالاً مشکل

----start_time   ببین چند دقیقه است داره اجرا میشه
--اگر Query ساده باشد ولی اینقدر طول کشیده باشد، معمولاً:

--Index ندارد
--Blocking دارد
--IO مشکل دارد

----تراکنش باز دارد؟
--گاهی Query اجرا نمی‌شود اما Transaction باز مانده و باعث Lock می‌شود.
SELECT
    s.session_id,
    s.login_name,
    s.open_transaction_count,
    s.status,
    s.last_request_start_time,
    s.last_request_end_time
FROM sys.dm_exec_sessions s
WHERE s.open_transaction_count > 0;

--:

--text
--BEGIN TRAN

--UPDATE table

---- developer forgot commit
--در این حالت:

--Lock باقی می‌ماند
--بقیه Queryها Block می‌شوند


--اگر مقدار آن بیشتر از صفر باشد یعنی Transaction هنوز Commit نشده.

--4. تشخیص Sleeping Session با Transaction باز
SELECT
    session_id,
    status,
    open_transaction_count,
    last_request_end_time
FROM sys.dm_exec_sessions
WHERE status = 'sleeping'
AND open_transaction_count > 0;

----یعنی:

--Session کاری نمی‌کند ولی Transaction را باز نگه داشته و Lock ایجاد کرده.

--5. بررسی Blocking Session
--اگر Query دیگران را Block کرده باشد:

SELECT
    session_id,
    blocking_session_id,
    wait_type,
    wait_time
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;

--در اینجا باید بروی سراغ Session مسدودکننده.
--در صورت نیاز Session مسدودکننده را با احتیاط KILL کن.
--Query مسدود شده را تحلیل کن (اغلب نیاز به Index یا Rewrite دارد).


---حالا مرحله 2 --2:سپس Top CPU Queries

--Top CPU Queries

SELECT TOP 10
    qs.total_worker_time / 1000 AS total_cpu_ms,
    qs.execution_count,
    (qs.total_worker_time / qs.execution_count) / 1000 AS avg_cpu_ms,
    qs.total_elapsed_time / 1000 AS total_duration_ms,
    qs.total_logical_reads,
    qs.total_logical_writes,
    st.text AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY qs.total_worker_time DESC;


--total_worker_time

--کل زمان CPU مصرف شده توسط Query

--واحد: microseconds

 --execution_count ---چند بار Query اجرا شده است.

 --avg_cpu_ms--میانگین CPU برای هر اجرا
 --total_worker_time / execution_count

-- این ستون خیلی مهم است.

--چون گاهی:

--Query سبک است
--ولی خیلی زیاد اجرا می‌شود


--total_elapsed_time
--کل زمان اجرای Query (CPU + Wait)

--اگر این مقدار خیلی بیشتر از CPU باشد یعنی Query در انتظار چیزی بوده:

--مثلاً

--IO
--Lock
--Memory

--total_logical_reads
--مقدار داده‌ای که Query از Buffer Pool خوانده است.

--اگر این مقدار زیاد باشد معمولاً:

--text
--Table Scan
--وجود دارد.


--total_cpu_ms = 2,000,000
--execution_count = 100
--avg_cpu_ms = 20000

--هر بار اجرا → 20 ثانیه CPU
--این Query بسیار سنگین است.

--total_cpu_ms = 2,000,000
--execution_count = 200000
--avg_cpu_ms = 10
--Query سبک است
--ولی بیش از حد اجرا می‌شود

--در این حالت مشکل معمولاً:

--Chatty application
--ORM بد
--Loop در Application


--بعد از پیدا کردن Query سنگین باید:

--1️⃣ Execution Plan را ببینی

SELECT *
FROM sys.dm_exec_query_plan(plan_handle)

2️⃣ Missing Index را بررسی کنی
3️⃣ Scan یا Hash Join سنگین را بررسی کنی
4️⃣ پارامترها را بررسی کنی
--Parameter Sniffing



--گاهی بهتر است Queryهایی را ببینی که الان CPU مصرف می‌کنند نه در گذشته

SELECT
    r.session_id,
    r.cpu_time,
    r.total_elapsed_time,
    r.status,
    t.text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
ORDER BY r.cpu_time DESC;
--این نشان می‌دهد در حال حاضر کدام Query CPU مصرف می‌کند.


--dm_exec_query_stats	CPU مصرف شده در گذشته
--dm_exec_requests	



----3:بعد Top IO Queries


--الهام، در مرحله 3 (Top IO Queries) هدف این است که Queryهایی را پیدا کنی که بیشترین خواندن یا نوشتن داده (IO) را دارند.

--در SQL Server معمولاً IO بالا باعث موارد زیر می‌شود:

--کند شدن Queryها
--فشار روی Disk
--افزایش Wait type مثل PAGEIOLATCH

--Top IO Queries
SELECT TOP 10
    qs.total_logical_reads AS total_reads,
    qs.total_logical_writes AS total_writes,
    qs.execution_count,
    (qs.total_logical_reads / qs.execution_count) AS avg_reads,
    (qs.total_logical_writes / qs.execution_count) AS avg_writes,
    st.text AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY qs.total_logical_reads DESC;
--مهم‌ترین شاخص IO است.

--total_logical_reads

--مهم‌ترین شاخص IO است.

--نشان می‌دهد Query چند Page از حافظه خوانده است.



--total_logical_reads = 1,000,000*8=8GB

