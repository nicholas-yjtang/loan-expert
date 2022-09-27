#!/bin/bash
mkdir -p /opt/loan-expert
wget -q -O clips_core_source_640.tar.gz https://sourceforge.net/projects/clipsrules/files/CLIPS/6.40/clips_core_source_640.tar.gz/download
tar xvf clips_core_source_640.tar.gz 
pushd clips_core_source_640/core
make -j
cp clips /opt/loan-expert/clips
popd