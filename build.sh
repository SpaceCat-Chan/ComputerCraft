#!/bin/bash
cd dig_area
cargo build --release
cd ..
cp dig_area/target/wasm32-unknown-unknown/release/dig_area.wasm ./
