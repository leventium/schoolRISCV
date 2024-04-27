SIM := iverilog

SIM_FLAGS := -I../src -I../src/crypto -I.
SIM_FLAGS += ../src/*.v ../src/crypto/riscv_*.v ./*.v
# SIM_FLAGS += -DXLEN=32 -DSBOXES=8

crypto_test:
	$(SIM) $(SIM_FLAGS) -stb_crypto -o res.out
	./res.out
