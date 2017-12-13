#!/bin/bash
. ~/entorn_BPOHISTP
export ORACLE_SID=BPOHISTP
rman cmdfile=recover_block.rman log=recover_block.log
