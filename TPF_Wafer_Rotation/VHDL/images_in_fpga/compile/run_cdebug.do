#############################################################
# vsimsa environment configuration
set dsn $curdir
log $dsn/log/vsimsa.log
@echo
@echo #################### Starting C Code Debug Session ######################
cd $dsn/src
amap images_in_fpga $dsn/images_in_fpga/images_in_fpga.lib
set worklib images_in_fpga
# simulation
asim -callbacks -O5 +access +r +m+tb_image_filter tb_image_filter behavior
run -all
#############################################################