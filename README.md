# ironic_setup
快速部署HPC裸机集群

### Step1
初始化netron网络的网卡配置

```

cd ironic_setup
sudo chmod 755 *.sh
sudo ./network-setup.sh
sudo reboot

```
### Step2
配置系统语言环境

```
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
sudo dpkg-reconfigure locales
```

在弹出的图形界面中选择en_US.UTF-8的编码，保存退出

### Step3
初始化kolla配置，部署基本ironic环境

```
sudo ./kolla_setup.sh

```

### Step4

```

ironic初始环境setup
sudo ./ironic_setup.sh

```

### Step5

```

```