bitcoinconsensus_testcases
===

These testcases are generated by running [afl-fuzz](http://lcamtuf.coredump.cx/afl/) against [libbitcoinconsensus](https://github.com/bitcoin/bitcoin/blob/15facb4aca75122b6ae0dcc6f6e112127e6a0e59/doc/release-notes/release-notes-0.10.0.md#consensus-library). 
They are pruned so only interesting testcases remain.
This is useful for testing agreement of bitcoin script execution between different versions and reimplementations.
See the 0.10-positive and 0.10-negative folders for testcases where script evaluation succeeded or failed. 
The btcd and bitcore folders contain programs to test reimplementations. 
[This blog post](https://jonasnick.github.io/blog/2015/05/09/fuzzing-bitcoin-consensus/) has a more detailed explanation.

Discovered Bugs
---
* conformal's btcd 
    * [f284b9b](https://github.com/btcsuite/btcd/commit/f284b9b3947eb33b91e31deec74936855feed61f): OP_IFDUP assumed less than 32 byte on the stack, OP_0 was different from a negative OP_EQUAL result

Fuzzing Instructions
---
* libbitcoinconsensus is contained in bitcoin core. Compile libbitcoinconsensus with afl-gcc and afl-g++.
* Run make inside the bitcoinconsensus_testcases folder to create valid_script.
* Run afl-fuzz with ./valid_script and supply examples, 0.10-positive or 0.10-negative as input.
* Run ./include_new.sh with the output of afl-fuzz, which prunes and includes your work into 0.10-\*.
* Open a pull request with the testcases folder.

Detailed Build Instructions
---

Building AFL:
```
wget http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz
tar -zxvf afl-latest.tgz
cd afl-<version>
make
export AFLPATH=$PWD
```

Build Bitcoin Core with instrumentation:
```
./configure --disable-ccache --enable-tests CC=${AFLPATH}/afl-gcc CXX=${AFLPATH}/afl-g++ --prefix=/path/to/local/bitcoin/build
export AFL_HARDEN=1
make
make install
```

Compile valid_script:
```
export AFLPATH=/path/to/local/afl/build
export BITCOINCOREPATH=/path/to/local/bitcoin/build
make
```

run bitcoinconsensus_testcases:
```
export LD_LIBRARY_PATH=/path/to/local/bitcoin/build
/path/to/local/afl/build/afl-fuzz -i 0.10-positive -o output -n /path/to/local/bitcoinconsensus_testcases/valid_script @@
```

valid_script.c
---
Expects a text file as input where the first line is the hex encoded scriptPubKey, the second line the hex encoded transaction, the third line an integer for the transaction index and the fourth line is an integer with the flags.

conformal's btcd
---
The btcd folder contains a go program that uses conformal's btcd packages, parses a file similar to valid_script and outputs 0 or 1. 
The detect_hardfork.sh script iterates through the input folder and reports if btcd and libbitcoinconsensus do not agree.

bitcore
---
Similar to btcd. 
Also contains a program valid_script_stack.c which can be used for more granular testing by directly comparing the top stack element of libbitcoinconsensus and bitcore after script execution. 
It takes only a scriptPubkey encoded as raw bytes and executes a [modified version of libbitcoinconsensus](https://github.com/jonasnick/bitcoin/tree/foo) with an empty scriptSig to retrieve the top stack element. 
Then it communicates with valid_script_stack_server.js via sockets to send the script and receive the top stack element after bitcore's execution.
If the elements differ valid_script_stack crashes.
Thus, we can use valid_script_stack directly with afl-fuzz.

TODO
---
* Add more reimplementations
