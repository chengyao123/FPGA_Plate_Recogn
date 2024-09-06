onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib cordic_opt

do {wave.do}

view wave
view structure
view signals

do {cordic.udo}

run -all

quit -force
