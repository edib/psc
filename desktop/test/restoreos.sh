#!/bin/bash




vagrant  halt "m1" 
vagrant  halt "m2" 
vagrant  halt "m3" 
vagrant  halt "b1" 
vagrant  halt "b2" 
vagrant  halt "p1" 
vagrant  halt "p2" 




vagrant snapshot restore "m1" os-m1
vagrant snapshot restore "m2" os-m2
vagrant snapshot restore "m3" os-m3
vagrant snapshot restore "b1" os-b1
vagrant snapshot restore "b2" os-b2
vagrant snapshot restore "p1" os-p1
vagrant snapshot restore "p2" os-p2


