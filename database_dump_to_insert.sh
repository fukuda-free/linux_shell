declare -A db_name_hash;
db_name_hash['dev-staging']='aiq_dev-staging';
db_name_hash['aiq_fukuda-verification']='aiq_veri-staging';
db_name_hash['kitdemo']='aiq_kitdemo';
db_name_hash['aiq_office_work']='aiq_office-work';
db_name_hash['demo']='aiq_demo';
db_name_hash['trialdemo']='aiq_trialdemo';
db_name_hash['aiq_office-kit']='aiq_office-kit';

for key in  ${!db_name_hash[*]} ;
do
    echo "${key} => ${db_name_hash[${key}]}" ;

    mysqldump -u'root' \
          -p'ypc06572' \
          --quick --single-transaction \
          -h'aiq-demo.czsaagem3vdf.us-west-2.rds.amazonaws.com' \
          ${key} > ${key}.bakcup

    mysql -u'ai_q' \
          -p'R30e-8gDxY96GeM' \
          -P 3306 \
          -h'aiq-demo-tokyo.c1hzjm8ctwzq.ap-northeast-1.rds.amazonaws.com' \
          ${db_name_hash[${key}]} < ${key}.bakcup

    echo "" ;
    echo "" ;
    echo "" ;
done
