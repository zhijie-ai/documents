hive:数据仓库
hive：解释器，编译器，优化器
	解释器：sql->.java文件
	编译器：.java->.class
	create database xiaojie
	hive在运行时有一些元数据要保存，默认保存到DBMS中
	把hdfs上的文件映射为关系型数据库逻辑结构
	映射关系，比如t_emp对应hdfs上的哪个目录
		id字段对应hdfs文件上的哪一列
	hive运行时，元数据存储在关系型数据库(如oracle)里面。(此时没装oracle)
	hive自带有一个关系型数据库，在hive-site.xml中，搜索url即可找到derby 
	
	yum install mysql-server
	mysql_install_db --user=mysql --ldata=/var/lib/mysql/ 
	
	load data local inpath '/home/hadoop/hive_data/emp.txt' into table t_emp;
	
创建分区表
	分区表实际上是一个文件夹，表明即文件夹名，每个分区，实际是表明这个文件夹下的不同文件
	分区可以根据时间地点等进行划分。比如，每天一个分区，
	等于每天存每天的数据，或者每个城市存每个城市的数据。每次写下类似where pt = 2010_08_23这样的条件
	即可查询指定时间的数据。
create table order_p(id int,ordertime string,goodtype int
	,price int,user_id int) partitioned by (order_day string) row 
	format delimited fields terminated by ',' stored as textfile;

HQL脚本有3种方式执行
1、hive -e 'hql' -->hive -e "select * from t_emp"
2、hive -f 'hql.file'
3、hive jdbc代码执行脚本

hive --service hiveserver2
hive并不是一个服务，如果要想用eclipse通过jdbc连接的话，
	可以通过上面那条命令启动一个服务，监听10000端口
修改hive-site.xml文件 hive.server2.thrift.bind.host这个属性配置的监听主机
hive.server2.long.polling.timeout这个属性的值5000L改为5000.
通过bin下的beeline客户端访问。
beeline
!connect jdbc:hive2://host66:10000/default

hiveserver2是连接hive的另一种方式,对比metastore,一种通过beeline，另一种通过代码中的jdbc
	并且还有一个好处是，可以在任意client连接hive，试想一下，代码中通过jdbc连接，
	是可以在任意一台电脑的。

hive有2种函数，UDF UDAF
UDF：输入数据为一条数据，输出数据也为一条数据
UDAF:输入数据为多条,count()函数

加载数据到hive表中
load命令，insert命令(有版本要求)

导出
1、将select的结果放到hdfs(export命令只能存处到hdfs文件系统上)
	export -->export table t_emp to '/usr/output/hive/t_emp';
	insert overwrite directory '/tmp/hive' select * from t_stu;(所有数据都挤到一起了,可以加建表时的分隔符)
2、将select的结果放到本地文件系统中
	insert overwrite local directory '/home/hadoop/hive_data/' ROW FORMAT DELIMITED FIELDS TERMINATED by ',' select * from t_stu;
	(这条命令会把目标路劲下的文件全部删除，谨慎使用)
	
	hive -e 'select * from t_emp' >> ~/test/emp.txt
	hive -f hive.sql >> ~/test/emp2.txt
	
	insert overwrite local directory '/tmp' row format delimited fields terminated by ',' select * from t_emp;

导入：http://blog.csdn.net/lifuxiangcaohui/article/details/40588929
1、从本地文件系统->hive表
	load命令
	load data local inpath '/opt/sxt/recommender/script/applist.txt' into table dim_rcm_hitop_id_list_ds
2、hdfs->hive表
	load命令，不需要local
3、从别的表中查询出相应的数据并导入到表中(dept_count表先要存在)
	insert into table dept_count select dept_name,count(1) from t_emp group by dept_name;
	hive还支持多表插入，如下：
	from wyp
	insert into table test
	select id,name,tel,age
	insert into table test3
	select id,name
	where age >25
	首先插入test表，id,name,tel,age4个字段，再插入test3表，2个字段
4、在创建表的时候通过从别的表中查询出相应的记录并插入到说创建的表中
	create table test4 as select * from wyp;原子操作。

导出
1、导出到本地文件系统
	insert overwrite local directory '/home/hadoop/hive_data/' select * from t_stu;
	以^A(ascii码为\00001)分割
2、导出到hdfs
	insert overwrite directory '/tmp/hive' select * from t_stu;
3、导出到hive的另外一张表
	insert into table test select * from wyp;
由于上面的导出使用的是默认的分隔符，可以在导出数据的时候自定义分隔符
insert overwrite local directory '/tmp' row format delimited fields terminated by ',' select * from t_emp;
还可以用-e 和-f参数来导出数据
hive -e 'select * from t_emp' >> ~/test/emp.txt
hive -f hive.sql >> ~/test/emp2.txt


三种模式：
local模式:连接derby数据库，一般用于测试
单用户模式：通过网络连接到一个数据库中
多用户模式(远程服务器模式)：用户非java客户端访问元数据库，在服务器端启动MetaStoreServer，
	客户端利用Thrift协议通过MetaStoreServer访问元数据库
	
本地derby
本地mysql(本地mysql数据库)
远端mysql
	remote一体(客户端和mysql数据库在一起)
	remote分开(客户端和服务器(metastoreserver)分开，通过thrift协议)

hive学习总结：
http://www.jianshu.com/p/3b9d0cf168a3
三种类型
临时表 temporary
	跟hive的session生命周期一致，hive client退出，表也一起删除了。临时表的优先级比
外部表 外部表数据的存储位置由自己制定； 
	删除数据时，仅仅会删除元数据，HDFS上的文件并不会被删除
内部表 数据存储的位置是hive.metastore.warehouse.dir（默认：/user/hive/warehouse）
	删除表时，会删除warehouse下的表及数据库中的元素据都删除
load hdfs上的文件时，会把hdfs上的文件移动到warehouse目录里，
load 本地数据时，本地数据依然会存在，并上传一份到hdfs上。

show create table M_BD_T_GAS_ORDER_INFO_H
desc formatted table_name;
show partitions table_name;
create table ptest(userid int) 
partitioned by (name string) 
row format delimited fields terminated by '\t'

CREATE EXTERNAL TABLE IF NOT EXISTS employee(eid int,name String,dept String)
PARTITIONED BY (year_p int)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

ALTER TABLE employee PARTITION (year_p='2017') 
RENAME TO PARTITION (year_p='2016');
分区是以字段的形式在表结构中存在

select unix_timestamp(’20111207 13:01:03′,’yyyyMMdd HH:mm:ss’)


SELECT unix_timestamp();
SELECT unix_timestamp(date_sub(from_unixtime(unix_timestamp()),30))
SELECT FROM_TIMESTAMP(now(),'yyyyMMdd')

SELECT date_sub(to_date(from_unixtime(unix_timestamp(),'yyyyMMdd HH:mm:ss')),30);
to_date 和FROM_TIMESTAMP的区别:前者只能获取日期字符串的日期部分，后者可以变成任意格式的日期字符串
from_unixtime 只能从时间戳(长整数)中变成任意格式的时间字符串

SELECT from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss');

select date_sub(from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss'),10);

SELECT unix_timestamp(date_sub(from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss'),10),'yyyy-MM-dd HH:mm:ss')
SELECT from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss');
SELECT date_sub(from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss'),10)
SELECT unix_timestamp(date_sub(from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss'),10),'yyyy-MM-dd')

SELECT unix_timestamp(to_date(date_sub(from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss'),10)));


SELECT request_uri_uuid,
         count(1) num
  FROM statistics_data.pv_anapp
  WHERE site = 'anapp'
   AND concat(month,day) between '20180601' and '20180630'
   AND request_uri_dmch_page LIKE '%/jianzhi/search/index%'
  GROUP BY  request_uri_uuid
  having count(1)>30 limit 10;
	

select from_unixtime(1469202502,'yyyy-MM-dd HH:mm:ss');
select UNIX_TIMESTAMP('2017-12-23 02:32:52')
select from_unixtime(UNIX_TIMESTAMP('2017-12-23 02:32:52'),'yyyyMMdd')

select substring(1469202502008,0,10);

select from_unixtime(cast(substring(1469202502008,1,10) as bigint),'yyyy-MM-dd HH:mm:ss')

desc ods.ods_jianzhi_jz_profile;
SELECT datediff('20131017', '20131015');
SELECT * from ods.ods_jianzhi_jz_profile limit 2;
SELECT year(from_unixtime(unix_timestamp(),'yyyy-MM-dd'))+2;
select substr('201212',0,4)+2;

desc doumi_dw.dw_user_info_wcb_invite_detail_d;
SELECT * from ods.ods_jz_apply limit 2;

msck repair table test;


set hive.exec.parallel=true
hive.exec.parallel.thread.number
动态分区的严格模式
set hive.mapred.mode=strict
order by,对结果做全排序，只允许有一个reduce处理
sort by 对单个reduce的数据进行排序
distribute by 分区排序，经常和sort by结合使用
cluster by 相当于sort by+distribute by

分桶的场景:抽样，map join