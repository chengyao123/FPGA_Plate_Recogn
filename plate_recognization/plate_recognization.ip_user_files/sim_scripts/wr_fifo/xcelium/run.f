-makelib xcelium_lib/xil_defaultlib -sv \
  "E:/FPGA/Vivado/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "E:/FPGA/Vivado/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "E:/FPGA/Vivado/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_3 \
  "../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_3 \
  "../../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_3 \
  "../../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../plate_recognization.srcs/sources_1/ip/wr_fifo/sim/wr_fifo.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

