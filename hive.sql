hive:���ݲֿ�
hive�������������������Ż���
	��������sql->.java�ļ�
	��������.java->.class
	create database xiaojie
	hive������ʱ��һЩԪ����Ҫ���棬Ĭ�ϱ��浽DBMS��
	��hdfs�ϵ��ļ�ӳ��Ϊ��ϵ�����ݿ��߼��ṹ
	ӳ���ϵ������t_emp��Ӧhdfs�ϵ��ĸ�Ŀ¼
		id�ֶζ�Ӧhdfs�ļ��ϵ���һ��
	hive����ʱ��Ԫ���ݴ洢�ڹ�ϵ�����ݿ�(��oracle)���档(��ʱûװoracle)
	hive�Դ���һ����ϵ�����ݿ⣬��hive-site.xml�У�����url�����ҵ�derby 
	
	yum install mysql-server
	mysql_install_db --user=mysql --ldata=/var/lib/mysql/ 
	
	load data local inpath '/home/hadoop/hive_data/emp.txt' into table t_emp;
	
����������
	������ʵ������һ���ļ��У��������ļ�������ÿ��������ʵ���Ǳ�������ļ����µĲ�ͬ�ļ�
	�������Ը���ʱ��ص�Ƚ��л��֡����磬ÿ��һ��������
	����ÿ���ÿ������ݣ�����ÿ�����д�ÿ�����е����ݡ�ÿ��д������where pt = 2010_08_23����������
	���ɲ�ѯָ��ʱ������ݡ�
create table order_p(id int,ordertime string,goodtype int
	,price int,user_id int) partitioned by (order_day string) row 
	format delimited fields terminated by ',' stored as textfile;

HQL�ű���3�ַ�ʽִ��
1��hive -e 'hql' -->hive -e "select * from t_emp"
2��hive -f 'hql.file'
3��hive jdbc����ִ�нű�

hive --service hiveserver2
hive������һ���������Ҫ����eclipseͨ��jdbc���ӵĻ���
	����ͨ������������������һ�����񣬼���10000�˿�
�޸�hive-site.xml�ļ� hive.server2.thrift.bind.host����������õļ�������
hive.server2.long.polling.timeout������Ե�ֵ5000L��Ϊ5000.
ͨ��bin�µ�beeline�ͻ��˷��ʡ�
beeline
!connect jdbc:hive2://host66:10000/default

hiveserver2������hive����һ�ַ�ʽ,�Ա�metastore,һ��ͨ��beeline����һ��ͨ�������е�jdbc
	���һ���һ���ô��ǣ�����������client����hive������һ�£�������ͨ��jdbc���ӣ�
	�ǿ���������һ̨���Եġ�

hive��2�ֺ�����UDF UDAF
UDF����������Ϊһ�����ݣ��������ҲΪһ������
UDAF:��������Ϊ����,count()����

�������ݵ�hive����
load���insert����(�а汾Ҫ��)

����
1����select�Ľ���ŵ�hdfs(export����ֻ�ܴ洦��hdfs�ļ�ϵͳ��)
	export -->export table t_emp to '/usr/output/hive/t_emp';
	insert overwrite directory '/tmp/hive' select * from t_stu;(�������ݶ�����һ����,���Լӽ���ʱ�ķָ���)
2����select�Ľ���ŵ������ļ�ϵͳ��
	insert overwrite local directory '/home/hadoop/hive_data/' ROW FORMAT DELIMITED FIELDS TERMINATED by ',' select * from t_stu;
	(����������Ŀ��·���µ��ļ�ȫ��ɾ��������ʹ��)
	
	hive -e 'select * from t_emp' >> ~/test/emp.txt
	hive -f hive.sql >> ~/test/emp2.txt
	
	insert overwrite local directory '/tmp' row format delimited fields terminated by ',' select * from t_emp;

���룺http://blog.csdn.net/lifuxiangcaohui/article/details/40588929
1���ӱ����ļ�ϵͳ->hive��
	load����
	load data local inpath '/opt/sxt/recommender/script/applist.txt' into table dim_rcm_hitop_id_list_ds
2��hdfs->hive��
	load�������Ҫlocal
3���ӱ�ı��в�ѯ����Ӧ�����ݲ����뵽����(dept_count����Ҫ����)
	insert into table dept_count select dept_name,count(1) from t_emp group by dept_name;
	hive��֧�ֶ����룬���£�
	from wyp
	insert into table test
	select id,name,tel,age
	insert into table test3
	select id,name
	where age >25
	���Ȳ���test��id,name,tel,age4���ֶΣ��ٲ���test3��2���ֶ�
4���ڴ������ʱ��ͨ���ӱ�ı��в�ѯ����Ӧ�ļ�¼�����뵽˵�����ı���
	create table test4 as select * from wyp;ԭ�Ӳ�����

����
1�������������ļ�ϵͳ
	insert overwrite local directory '/home/hadoop/hive_data/' select * from t_stu;
	��^A(ascii��Ϊ\00001)�ָ�
2��������hdfs
	insert overwrite directory '/tmp/hive' select * from t_stu;
3��������hive������һ�ű�
	insert into table test select * from wyp;
��������ĵ���ʹ�õ���Ĭ�ϵķָ����������ڵ������ݵ�ʱ���Զ���ָ���
insert overwrite local directory '/tmp' row format delimited fields terminated by ',' select * from t_emp;
��������-e ��-f��������������
hive -e 'select * from t_emp' >> ~/test/emp.txt
hive -f hive.sql >> ~/test/emp2.txt


����ģʽ��
localģʽ:����derby���ݿ⣬һ�����ڲ���
���û�ģʽ��ͨ���������ӵ�һ�����ݿ���
���û�ģʽ(Զ�̷�����ģʽ)���û���java�ͻ��˷���Ԫ���ݿ⣬�ڷ�����������MetaStoreServer��
	�ͻ�������ThriftЭ��ͨ��MetaStoreServer����Ԫ���ݿ�
	
����derby
����mysql(����mysql���ݿ�)
Զ��mysql
	remoteһ��(�ͻ��˺�mysql���ݿ���һ��)
	remote�ֿ�(�ͻ��˺ͷ�����(metastoreserver)�ֿ���ͨ��thriftЭ��)

hiveѧϰ�ܽ᣺
http://www.jianshu.com/p/3b9d0cf168a3
��������
��ʱ�� temporary
	��hive��session��������һ�£�hive client�˳�����Ҳһ��ɾ���ˡ���ʱ������ȼ���
�ⲿ�� �ⲿ�����ݵĴ洢λ�����Լ��ƶ��� 
	ɾ������ʱ��������ɾ��Ԫ���ݣ�HDFS�ϵ��ļ������ᱻɾ��
�ڲ��� ���ݴ洢��λ����hive.metastore.warehouse.dir��Ĭ�ϣ�/user/hive/warehouse��
	ɾ����ʱ����ɾ��warehouse�µı����ݿ��е�Ԫ�ؾݶ�ɾ��
load hdfs�ϵ��ļ�ʱ�����hdfs�ϵ��ļ��ƶ���warehouseĿ¼�
load ��������ʱ������������Ȼ����ڣ����ϴ�һ�ݵ�hdfs�ϡ�

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
���������ֶε���ʽ�ڱ�ṹ�д���

select unix_timestamp(��20111207 13:01:03��,��yyyyMMdd HH:mm:ss��)


SELECT unix_timestamp();
SELECT unix_timestamp(date_sub(from_unixtime(unix_timestamp()),30))
SELECT FROM_TIMESTAMP(now(),'yyyyMMdd')

SELECT date_sub(to_date(from_unixtime(unix_timestamp(),'yyyyMMdd HH:mm:ss')),30);
to_date ��FROM_TIMESTAMP������:ǰ��ֻ�ܻ�ȡ�����ַ��������ڲ��֣����߿��Ա�������ʽ�������ַ���
from_unixtime ֻ�ܴ�ʱ���(������)�б�������ʽ��ʱ���ַ���

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
��̬�������ϸ�ģʽ
set hive.mapred.mode=strict
order by,�Խ����ȫ����ֻ������һ��reduce����
sort by �Ե���reduce�����ݽ�������
distribute by �������򣬾�����sort by���ʹ��
cluster by �൱��sort by+distribute by

��Ͱ�ĳ���:������map join