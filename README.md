# Notes

Every system has details and its important to understand that tweaks may be necessary.

In order to achieve my set up I've read multiple guides and documentations and looked in different places. While setting things up stuff may not work has intended so debug needs to happen. The guide that most help me due to the files that has and the clear explanation was "WORMSTweaker Guide", files that the guide has are in the folder WORMSTweaker Guide. I needed to do some modifications so I explain all, just keep reading.

I HIGHLY suggest that you do your reasearch about gpu passthrough, specially if you have a set up like mine, one and one only graphic PCI... Sometimes programmers do stuff one way, and that way may not work for your system, so you need to adapt.

Backup anything you dont want to lost just in case you need to do a clean install of your linux in the middle of the way

# My set up:
- Ubuntu 24.04.1 LTS
- intel i9 10900KF ( NO INTEGRATED GRAPHICS )
- GEFORCE RTX 3050
- QEMU/KVM
- VIRT MANAGER

# Set up

This tells you some steps I've done to make my VM with single gpu passthrough. I only show steps for intel cpu and nvidia graphics card.

- Lets start by checking nvidia drivers with: `lspci -k | grep -A 3 -i nvidia`
- If we want to see if any are blacklisted we can do: `grep -i drivername /etc/modprobe.d/*`
- I blacklist the nouveau driver doing: `sudo nano /etc/modprobe.d/blacklist-nouveau.conf`
- Now add this two lines: `blacklist nouveau` and `options nouveau modeset=0`
- Don't forget to regenerate the initial RAM: `sudo update-initramfs -u`
- Check about IOMMU and VT-D or VT-X, this is defined in the BIOS of your system. You can turn you computer off and go to BIOS and check it there, both should be enable. VT-D or VT-X are the option, virtualization I believe.
- Now you want to add `intel_iommu=on` to the file: `/etc/default/grub` and update grub after with `sudo update-grub`
- Enable SSH connection, because in this case that's the only way to connect back to the host...
- Start by checking with `sudo systemctl status ssh`; If inactive, do `sudo systemctl start ssh`, them `sudo systemctl enable ssh`; If you don't have it, install it: `sudo apt install openssh-server`
- Now allow ssh, check the firewall: `sudo ufw status`, them `sudo ufw allow ssh`; You can active it if inactive: `sudo ufw enable`
- install the needed packages: `sudo apt install libvirt-daemon-system libvirt-clients qemu-kvm qemu-utils virt-manager ovmf`
- Reboot your system
- Related to dumping your ROM, do a BIG research about this and specially for your device, depending on the GPU you have things can change and some error may cause your GPU to break. Things I avoid: ROM files; Using a ROM file even if from a trusted source may cause issues, you don't know when that file was dumped and how it was done.
- After my research I realize that getting the `nvflash` from `TechPoweredUp` and dump the ROM myself was the best step to take. To do this you need to go in a TTY, disable gdm or the display your using, I use gnome so I do `sudo systemctl stop gdm`; them disable all nvidia drivers with rmmod: `sudo rmmod driver name`; now you can dump your ROM, after that enable all nvidia drivers with modprobe: `sudo modprobe driver name` and display manager `sudo systemctl restart gdm` or just reboot your host with `sudo reboot` instead.
- Your ROM should be patched before you use it in your VM, WORMSTweaker guide explain how very good: https://gitlab.com/risingprismtv/single-gpu-passthrough/-/wikis/6)-Preparation-and-placing-of-the-ROM-file
- Related to scripts that will automate the GPU passthrough when you launch your VM, it's not that many so I installed scripts manually, the path is the name of the folder. There's a few different ways of doing this and you can see a few in the links bellow. I installed the scripts manually because all the ways that are described in those links where giving me errors. Some scripts where giving me errors too so I needed to debug and do some error handling. This way I have my version of scripts in the folder ''myScritps'' and the original scripts in the folder ''WORMSTweaker''. Do your research and see which way is better for you. If your scripts don't load for some reason it can be because of apparmor. I needed to change the `vfio-start` and `vfio-teardown` to the folder /bin/, otherwise apparmor will block their execution.

# Making the VM

Now if you complete beginner to this, you're probably overwhelm with this guide already... If so go in this link to follow some good visual instructions from WORMSTweaker guide: (https://gitlab.com/risingprismtv/single-gpu-passthrough/-/wikis/home). 

If you're not a beginner to this, them make your VM. Here's some important notes I've take:

- Before you proceed to install you need to check the box: `Customize configuration before install`
- If using Q35 select UEFI firmware, I read that windows 11 need secure boot, so if you're not in windows 11 don't use secure boot.
- For the CPU you want to have `host-passthrough` and check `Enable available CPU security flaw mitigations`; Open the topology to make yours manually, set the `sockets` to 1, the `cores` and the `threads` to the number you desire. 
- For the disk usually VirtIO disk with writeback cache mode can be the fastest option.
- You need to add hardware, to add the VirtIO ISO, click on `Add Hardware`, them `Storage`, them `Select or create a custom storage`, select your ISO and make sure its `CDROM device`
- virtio DRIVERS: https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md

When this basic settings are set, proceed to installation

- Once you make your VM run it the first time without GPU passthrough. This way you can install windows. After that shut the VM down and modify the xml file with `virsh edit vmname` I used nano editor. If you have trouble with savings you can use `sudo`. Using nano editor is good because if something is wrong with the file, tells you once you try to save it. You can check my xml version in this repo.
- You can check my xml folder to see which options I've added. There's a performance folder that contains some tweaks I've done and explanation

# GPU Passthrough

To do this you need to delete all the `spice` devices in your VM, otherwise it will conflict with the GPU, I do it while editing my XML. Don't forget to add the path to your ROM file in the configuration of your GPU

Make sure to check the scripts because that's the only thing that will allow the system to leave the host and bind to the VM.

I've copy the custom_hooks.log file to this repo that you can take a look and see what kinda problems I was having to debug. You should check other log files in the folder `/var/log/libvirt` this folder has details about your vm when it starts and when shuts down, if some things are going wrong here you can see why.

The vfio-teardown hook was mainly, all re-writed...

# WORMSTweaker guide

Scripts for passing a single GPU from a Linux host to a Windows VM and back.

1. Change the VM name in qemu if not already win10
2. Run the install_hooks.sh script as root

Note the PCI ids and display manager should be detected automatically. If you are using an unsupported display manager that is not listed in the hooks/vfio-startup.sh script, feel free to contact us on the Discord server and we shall add your display manager.

If using startx, add a line `killall -u user_name` to qemu/vfio-startup.sh script towards the beginning and you can add a line to vfio-teardown.sh to start your window manager/ desktop environment again. Don't just add startx because it will be run as root. Instead add `su -s /bin/bash -c "/usr/bin/startx" -g username username` replacing username with your username to the end of the vfio-teardown.sh script.

For a detailled guide on how to use these scripts, [check out the the wiki of this repo.](https://gitlab.com/risingprismtv/single-gpu-passthrough/-/wikis/home)

For suggestions or support, join us on Discord at: https://discord.gg/bh4maVc

# Bryansteiner guide

This guide explains a lot about VM performance, it has other way of using the hooks too.

- https://github.com/bryansteiner/gpu-passthrough-tutorial?tab=readme-ov-file

# Other useful links:
- https://ubuntu.com/server/docs/gpu-virtualization-with-qemu-kvm

- https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#%22Error_43:_Driver_failed_to_load%22_on_Nvidia_GPUs_passed_to_Windows_VMs

- https://github.com/BigAnteater/KVM-GPU-Passthrough/tree/main?tab=readme-ov-file


