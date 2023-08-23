#!/bin/bash

# 需要上传文件的本地路径
transport_dir=""
curr_date=$(date +%Y%m%d)
data_dir="${curr_date}_back/"
# 目标服务器 ip
sftp_from_ip=""
# 目标服务器端口
sftp_from_port="22"
# 用户名
sftp_from_user=""
# 密码
sftp_from_password=""
# 目标服务器文件存储目录
sftp_from_dir=""

echo $transport_dir"$data_dir"

expect <<-EOF
      set timeout 3
      spawn sftp -P $sftp_from_port $sftp_from_user@$sftp_from_ip
      expect {
          "yes/no" { exp_send "yes\r";exp_continue }
          "password" { exp_send "$sftp_from_password\r" }
      }
      expect "password" { send "$sftp_from_password\r" }
      expect "sftp"
      send "mkdir $sftp_from_dir\r"
      expect "sftp"
      send "ls $sftp_from_dir\r"
      expect "sftp"
      send "exit\r"
      expect eof
EOF

filenames=$(ls $transport_dir"$data_dir")
echo "${filenames[*]}"
for filename in $filenames
do
    echo $transport_dir"$filename"
    data_path=$transport_dir$data_dir$filename
    # 打印下执行命令
    # echo "scp -P $sftp_from_port $data_path $sftp_from_user@$sftp_from_ip:$sftp_from_dir$filename"
    # sftp 上传文件
    expect <<- EOF
      set timeout 5
      spawn sftp -P $sftp_from_port $sftp_from_user@$sftp_from_ip
      expect {
          "yes/no" { exp_send "yes\r";exp_continue }
          "password" { exp_send "$sftp_from_password\r" }
      }
      expect "password" { send "$sftp_from_password\r" }
      expect "sftp"
      send "put $data_path $sftp_from_dir\r"
      set timeout -1
      expect "100%"
      send "exit\r"
      expect eof
EOF
done