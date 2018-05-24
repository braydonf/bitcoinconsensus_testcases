valid_script: valid_script.c
	${AFLPATH}/afl-gcc -I${BITCOINCOREPATH}/include/ -L${BITCOINCOREPATH}/lib/ -o valid_script valid_script.c -lssl -lcrypto -lstdc++ -lbitcoinconsensus
