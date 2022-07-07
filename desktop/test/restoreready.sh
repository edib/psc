#!/bin/bash


vagrant halt m1 
vagrant halt m2 
vagrant halt m3 
vagrant halt b1 
vagrant halt b2 
vagrant halt p1 
vagrant halt p2 

vagrant snapshot restore "m1" ready-m1
vagrant snapshot restore "m2" ready-m2
vagrant snapshot restore "m3" ready-m3
vagrant snapshot restore "b1" ready-b1
vagrant snapshot restore "b2" ready-b2
vagrant snapshot restore "p1" ready-p1
vagrant snapshot restore "p2" ready-p2


