#!/usr/bin/bash
while ((1))
do
echo "
******************一键巡检******************
-------------------------------------------
1.巡检管局FTP IP Ping
-------------------------------------------
2.巡检管局指令接口
-------------------------------------------
3.巡检采集服务器采集目录积压
-------------------------------------------
4.清理采集服务器Error目录/文件(谨慎使用!!!)
-------------------------------------------
5.Ping 测试
-------------------------------------------
0.退出
-------------------------------------------
"

read -p "请输入选项：" choice

case ${choice} in
  1)   #ping 5 次，ping超时时间10s
    read -p "请输入WEB IP：" web_ip
    read -p "请输入管局FTP IP：" ftp_ip
    ssh ${web_ip}  "ping -c 5 -w 10 ${ftp_ip}" 
    ;;

  2)   #测试管局端口连通性
    read -p "请输入WEB IP：" web_ip
    read -p "请输入管局接口 IP:端口 ：" inter_ip
    ssh ${web_ip} "curl http://${inter_ip}/IDCWebService/commandack?wsdl" 
    ;;

  3)   #查询采集目录是否积压
    read -p "请输入采集IP列表文件名：" ip_list
    read -p "请输入积压查询目录：" dir_path   
    
    if [ -e check_result ];then
       echo "" > check_result
    else 
       touch check_result
    fi

    if [[ ${dir_path} = "/ftpdata/data" ]];then
      for ip in `cat ${ip_list}`
      do
         echo -e "\n IP is ${ip}" >> check_result   #shell默认关闭转义字符解释， -e 开启 ， -E 默认关闭
         echo "`ssh ${ip} "ls ${dir_path}/*/*"`" >> check_result   #加双引号将结果格式化成字符串
      done
    else 
      for ip in `cat ${ip_list}`
      do
         echo -e "\n IP is ${ip}" >> check_result   #shell默认关闭转义字符解释， -e 开启 ， -E 默认关闭
         echo "`ssh ${ip} "ls ${dir_path}/*"`" >> check_result   #加双引号将结果格式化成字符串
      done
    fi
    ;;

  4)   #清理err或者error目录
    read -p "请输入采集IP列表文件名：" ip_list
    read -p "请输入清理目录：" dir_path
    if [[ ${dir_path} = "/ftpdata/data" \
          || ${dir_path} = "/ftpdata/bsmp/data" \
          || ${dir_path} = "/" \
          || ${dir_path} = "/ftpdata" \
          || ${dir_path} = "/ftpdata/bsmp" ]];then 
      echo "错误，请重新输入文件夹"
      continue
    else
      for ip in `cat ${ip_list}`
      do
        echo "IP is ${ip}"
        ssh ${ip} "rm -rf ${dir_path}"
      done
    fi
    ;;

#  0)
esac

if [ ${choice} -eq 0 ];then
  break
fi

done
