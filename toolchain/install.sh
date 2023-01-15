#!/bin/sh

TOOLCHAIN_PATH=$(readlink -f $1)
LOCAL_DIR=$(dirname $(readlink -f $0))

mkdir -p $TOOLCHAIN_PATH

cd $TOOLCHAIN_PATH && cat $LOCAL_DIR/../toolchain.txt \
                    | sed '/^#other/q' | sed '/^#/d' \
                    | xargs $LOCAL_DIR/getFPGAwars.sh
ls *.tar.gz | while read i; \
              do \
                rm -rf ${i%%.tar.gz}; \
                mkdir ${i%%.tar.gz}; \
                tar xzf $i -C ${i%%.tar.gz}; \
                rm $i; \
              done


cd $TOOLCHAIN_PATH && cat $LOCAL_DIR/../toolchain.txt \
                  | sed '/^#/d' | grep "istyle" \
                  && mkdir -p ./istyle/bin && cd ./istyle/bin \
                  && $LOCAL_DIR/getGithub.sh MuratovAS/istyle-verilog-formatter istyle \
                  && chmod 775 istyle

cd $TOOLCHAIN_PATH && cat $LOCAL_DIR/../toolchain.txt \
                  | sed '/^#/d' | grep "simplevcd" \
                  && mkdir -p ./simplevcd/bin && cd ./simplevcd/bin \
                  && $LOCAL_DIR/getGithub.sh MuratovAS/simpleVCD simplevcd \
                  && chmod 775 simplevcd

cd $TOOLCHAIN_PATH && cat $LOCAL_DIR/../toolchain.txt \
                  | sed '/^#/d' | grep "verilog-format" \
                  && mkdir -p ./verilog-format/bin && cd ./verilog-format/bin \
                  && $LOCAL_DIR/getGithub.sh MuratovAS/verilog-format verilog-format.jar

cd $TOOLCHAIN_PATH && cat $LOCAL_DIR/../toolchain.txt \
                  | sed '/^#/d' | grep "toolchain-riscv32i" \
                  && $LOCAL_DIR/getGithub.sh MuratovAS/toolchain-riscv32i toolchain-riscv32i.tar.gz \
                  && tar -xvf toolchain-riscv32i.tar.gz \
                  && rm toolchain-riscv32i.tar.gz

cd $TOOLCHAIN_PATH && cat $LOCAL_DIR/../toolchain.txt \
                  | sed '/^#/d' | grep "toolchain-sdcc" \
                  && curl -L https://sourceforge.net/projects/sdcc/files/sdcc-linux-amd64/4.0.0/sdcc-4.0.0-amd64-unknown-linux2.5.tar.bz2 > "sdcc.tar.bz2" \
                  && tar -xvf sdcc.tar.bz2 \
                  && rm sdcc.tar.bz2 \
                  && curl -L https://sourceforge.net/projects/srecord/files/srecord/1.65/srecord-1.65.0-Linux.tar.gz > "srecord.tar.gz" \
                  && tar -xvf srecord.tar.gz \
                  && rm srecord.tar.gz

echo "Installation completed"