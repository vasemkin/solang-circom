#!/usr/bin/env bash

mkdir -p build
mkdir -p dist
wget -nc https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_15.ptau -P ./build

circom tests/circuits/MultiplierTest.circom --wasm --r1cs -o ./build
npx snarkjs groth16 setup build/MultiplierTest.r1cs build/powersOfTau28_hez_final_15.ptau build/MultiplierTest.zkey

circom circom/Verifier.circom --r1cs -o ./dist
circom circom/Verifier.circom --wasm -o ./build

npx snarkjs groth16 setup dist/Verifier.r1cs build/powersOfTau28_hez_final_15.ptau build/Verifier.zkey
npx snarkjs zkey export verificationkey build/Verifier.zkey build/Verifier_vkey.json
npx snarkjs zkey export solidityverifier build/Verifier.zkey solidity/verifier.sol

sed -i -e 's/pragma solidity \^0.6.11/pragma solidity 0.8.17/g' solidity/verifier.sol

npx wasm2js build/Verifier_js/Verifier.wasm -o src/Verifier.js