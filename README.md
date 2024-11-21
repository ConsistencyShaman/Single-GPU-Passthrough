# Notes

Every system has details and its important to understand that tweaks may be necessary.

In order to achieve my set up I've read multiple guides and documentations and looked in different places. While setting things up stuff may not work has intended so debug needs to happen. The guide that most help me due to the files that has and the clear explanation its in the section "Single GPU Passthrough" has the files that the guide has are in the folder WORMSTweaker Guide. I needed to do some modifications so I explain all, just keep reading.

I HIGHLY suggest that you do your reasearch about gpu passthrough, specially if you have a set up like mine, one and one only graphic PCI... Sometimes programmers do stuff one way, and that way may not work for your system, so you need to adapt.

Backup anything you dont want to lost just in case you need to do a clean install of your linux in the middle of the way

# My set up:
- Ubuntu 24.04.1 LTS
- intel i9 10900KF ( NO INTEGRATED GRAPHICS )
- GEFORCE RTX 3050
- QEMU/KVM
- VIRT MANAGER

# What I've done

I choose to write some notes to this guide that I've follow because it was the one that felt more clear to me and add something that I needed and I could use that has a base. This set up that I have will not allow me to have graphical interface on host and guest at the same time, so I needed to set up SSH connection so that if I needed I can control the host from the guest. Something that I'm still looking at the fact that I need to log in back in ubuntu everytime I shut the VM, which I'll like to avoid. 

Most info that I follow is down on the link bellow "For a detailled guide on how to use these scripts.."

I'll tell you what I've changed to make my set up work because it didn't work just by following the guide... I've follow the guide till the step 6 (Preparation and placing of the ROM file), from there things changed for me:
- Lets start by checking nvidia drivers with: lspci -k | grep -A 3 -i nvidia
- If we want to see if any are blacklisted we can do: grep -i drivername /etc/modprobe.d/*
- I blacklist the nouveau driver doing: sudo nano /etc/modprobe.d/blacklist-nouveau.conf
- Now add this two lines:
  '''
  blacklist nouveau
  options nouveau modeset=0
  '''
- Dont forget to regenerte the initial RAM: sudo update-initramfs -u and them reboot
- Has my gpu is the 3050 I didnt dump the ROM and choose to try it without that step, it worked fine so I let it like that.
- Scripts and installation, I like to do things slow and look at everything so I read the installation script and decided that installing the scripts manually was better.
- The other 2 steps, 8 and 9 worked fine for me

The scripts is the most important has is the only thing that will allow the GPU passthrough to work correctly. I needed to modify a few things on both scripts, vfio-start and vfio-teardown. I'm minimalistic so I edited the scripts specially for my machine set up and needed to adjust a few things, you can look at myScripts folder to see and compare to the scripts on hooks folder.

If I'll store the scripts(the hooks) on /usr/local/bin the apparmor will block their execution so the VM will get stuck in initiallization. I've changed their location to /bin/ followed by editing the script that calls those two scripts (the hooks), the qemu script. If you intend to use multiple VMs with gpu passthrough you can do it by adding their name in the qemu script too.

I've copy the custom_hooks.log file to this repo that you can take a look and see what kinda problems I was having to debug. My solution went through write some error handling on the hooks and change the references that needed.

The vfio-teardown hook was mainly, all re-writed...

I've added some more usefull links that I looked at and where usefull. Dont forget to install the virtio drivers on the first VM boot, after installation! Only after that you'll do the passthrough.
- virtio DRIVERS: https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md

# Single GPU Passthrough Scripts

Scripts for passing a single GPU from a Linux host to a Windows VM and back.

1. Change the VM name in qemu if not already win10
2. Run the install_hooks.sh script as root

Note the PCI ids and display manager should be detected automatically. If you are using an unsupported display manager that is not listed in the hooks/vfio-startup.sh script, feel free to contact us on the Discord server and we shall add your display manager.

If using startx, add a line `killall -u user_name` to qemu/vfio-startup.sh script towards the beginning and you can add a line to vfio-teardown.sh to start your window manager/ desktop environment again. Don't just add startx because it will be run as root. Instead add `su -s /bin/bash -c "/usr/bin/startx" -g username username` replacing username with your username to the end of the vfio-teardown.sh script.

For a detailled guide on how to use these scripts, [check out the the wiki of this repo.](https://gitlab.com/risingprismtv/single-gpu-passthrough/-/wikis/home)

For suggestions or support, join us on Discord at: https://discord.gg/bh4maVc

other usefull links:
https://ubuntu.com/server/docs/gpu-virtualization-with-qemu-kvm

https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md

https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#%22Error_43:_Driver_failed_to_load%22_on_Nvidia_GPUs_passed_to_Windows_VMs

https://github.com/BigAnteater/KVM-GPU-Passthrough/tree/main?tab=readme-ov-file

https://github.com/bryansteiner/gpu-passthrough-tutorial?tab=readme-ov-file
