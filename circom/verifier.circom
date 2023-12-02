pragma circom 2.0.0;

include "multiplier.circom";

template Verifier() {
    signal input a;
    signal input b;
    signal output c;

    component multiplier = Multiplier();

    multiplier.a <== a;
    multiplier.b <== b;

    c <== multiplier.c;
}

component main = Verifier();