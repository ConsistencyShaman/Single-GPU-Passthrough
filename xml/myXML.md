## CPU features
- Here are some specs of my VM. Choosing to pin the cpu cores instead of leaving that to the emulator can be good for performance.
- Check the performance folder, there's a useful script to make the most out of your CPU
- To pin the cpu cores and threads correctly you should check them in the terminal
- `lscpu -e` to see cores and siblings, this way you can pin them togheter
- This link explains it very well: https://github.com/bryansteiner/gpu-passthrough-tutorial?tab=readme-ov-file
```
  <memory unit="KiB">20480000</memory>
  <currentMemory unit="KiB">20480000</currentMemory>
  <vcpu placement="static">14</vcpu>
  <iothreads>1</iothreads>
  <cputune>
    <vcpupin vcpu="0" cpuset="0"/>
    <vcpupin vcpu="1" cpuset="10"/>
    <vcpupin vcpu="2" cpuset="1"/>
    <vcpupin vcpu="3" cpuset="11"/>
    <vcpupin vcpu="4" cpuset="2"/>
    <vcpupin vcpu="5" cpuset="12"/>
    <vcpupin vcpu="6" cpuset="3"/>
    <vcpupin vcpu="7" cpuset="13"/>
    <vcpupin vcpu="8" cpuset="4"/>
    <vcpupin vcpu="9" cpuset="14"/>
    <vcpupin vcpu="10" cpuset="5"/>
    <vcpupin vcpu="11" cpuset="15"/>
    <vcpupin vcpu="12" cpuset="6"/>
    <vcpupin vcpu="13" cpuset="16"/>
    <emulatorpin cpuset="7"/>
    <iothreadpin iothread="1" cpuset="8-9,17-19"/>
  </cputune>
```

## Features
```
  <features>
    <acpi/>
    <apic/>
    <hyperv mode="custom">
      <relaxed state="on"/>
      <vapic state="on"/>
      <spinlocks state="on" retries="8191"/>
      <vpindex state="on"/>
      <synic state="on"/>
      <stimer state="on"/>
      <reset state="on"/>
      <vendor_id state="on" value="geforced"/>
      <frequencies state="on"/>
    </hyperv>
    <kvm>
      <hidden state="on"/>
    </kvm>
    <vmport state="off"/>
    <smm state="on"/>
```
## CPU
- A little under on the xml file you have this category, cpu, here you can add some features too
- When you add a feature with policy='disable' you basically are hiding that flag form the vm OS and not really disabling the feature 
```
  <cpu mode="host-passthrough" check="none" migratable="on">
    <topology sockets="1" dies="1" cores="7" threads="2"/>
    <cache mode="passthrough"/>
    <feature policy="disable" name="smep"/>
  </cpu>
  <clock offset="localtime">
    <timer name="rtc" tickpolicy="catchup"/>
    <timer name="pit" tickpolicy="delay"/>
    <timer name="hpet" present="no"/>
    <timer name="hypervclock" present="yes"/>
  </clock>
```
## GPU
- Example of a GPU passthrough with ROM file attached:
```
<hostdev mode="subsystem" type="pci" managed="yes">
  <source>
    <address domain="0x0000" bus="0x01" slot="0x00" function="0x0"/>
  </source>
  <rom file="/usr/share/vgabios/patched.rom"/>
  <address type="pci" domain="0x0000" bus="0x06" slot="0x00" function="0x0"/>
</hostdev>
```
