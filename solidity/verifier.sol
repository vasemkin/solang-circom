import { curves } from "./curves.sol";
import "solana";

//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// 2019 OKIMS
//      ported to solidity 0.6
//      fixed linter warnings
//      added requiere error messages
//
//
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }

    /// @return the generator of G1
    function P1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() internal pure returns (G2Point memory) {
        // Original code point
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );

/*
        // Changed by Jordi point
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
*/
    }
    /// @return r the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) internal pure returns (G1Point memory r) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }

    function bytes32ToUint(bytes memory data, uint n) public pure returns (uint result) {
        require(n * 32 + 32 <= data.length, "Index out of bounds");

        for (uint i = 0; i < 32; i++) {
            result |= uint(uint8(data[n * 32 + i])) << (8 * (31 - i));
        }
    }

    function concat(bytes memory a, bytes memory b, bytes memory c, bytes memory d) internal pure returns (bytes memory) {
        return abi.encodePacked(a, b, c, d);
    }

    function concat3(bytes memory a, bytes memory b, bytes memory c) internal pure returns (bytes memory) {
        return abi.encodePacked(a, b, c);
    }

     function uintArrayToBytes(uint[] memory arr) public pure returns (bytes memory) {
         // Calculate the total bytes required
        // Assuming each uint is a uint256, which is 32 bytes
        uint totalBytes = arr.length * 32;
        bytes memory b = new bytes(totalBytes);

        uint byteIndex = 0;
        for (uint i = 0; i < arr.length; i++) {
            // Convert uint to bytes and store in the bytes array
            for(uint j = 0; j < 32; j++) {
                b[byteIndex++] = bytes32(arr[i])[j];
            }
        }

        return b;
    }

    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        // Declare rustCalldata as bytes
        bytes memory rustCalldata = concat(
            bytes32(p1.X), 
            bytes32(p1.Y), 
            bytes32(p2.X), 
            bytes32(p2.Y)
        );

        bytes result = curves.addition{accounts: []}(rustCalldata);        

        r.X = bytes32ToUint(result, 0);
        r.Y = bytes32ToUint(result, 1);
    }

    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
         // Declare rustCalldata as bytes
        bytes memory rustCalldata = concat3(
            bytes32(p.X), 
            bytes32(p.Y), 
            bytes32(s)
        );

        bytes result = curves.multiplication{accounts: []}(rustCalldata);        

        r.X = bytes32ToUint(result, 0);
        r.Y = bytes32ToUint(result, 1);        
    }


    function pairingTest(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bytes) {
        require(p1.length == p2.length,"pairing-lengths-failed");
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;

        bytes memory rustCalldata = uintArrayToBytes(input);

        bytes result = curves.pairing{accounts: []}(rustCalldata);       

        return (result);
    }

    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length,"pairing-lengths-failed");
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;

        bytes memory rustCalldata = uintArrayToBytes(input);

        bytes result = curves.pairing{accounts: []}(rustCalldata);       

        return (result.length != 0);
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

@program_id("FaAbS83pjtas4kHid7PwZuPBS1uuJi2asRihhFghCq92") // on-chain program address
contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }


    @payer(payer)
    constructor() {}

    function testGetter() public pure returns (bool) {
        return true;
    }



    function tryAddition() public view returns (Pairing.G1Point memory r) {
        return Pairing.addition(verifyingKey().IC[0], verifyingKey().IC[1]);
    }

    function tryMul() public view returns (Pairing.G1Point memory init, Pairing.G1Point memory r) {
        return (Pairing.G1Point( 
            6819801395408938350212900248749732364821477541620635511814266536599629892365,
            9092252330033992554755034971584864587974280972948086568597554018278609861372
        ), Pairing.scalar_mul(verifyingKey().IC[0], 1));
    }


    function tryPairing() public view returns (bytes) {
        Pairing.G1Point[] memory p1Inputs = new Pairing.G1Point[](1);

        p1Inputs[0] = Pairing.G1Point( 
            6819801395408938350212900248749732364821477541620635511814266536599629892365,
            9092252330033992554755034971584864587974280972948086568597554018278609861372
        );

        Pairing.G2Point[] memory p2Inputs = new Pairing.G2Point[](1);

        p2Inputs[0] = Pairing.G2Point(
            [4252822878758300859123897981450591353533073413197771768651442665752259397132,
             6375614351688725206403948262868962793625744043794305715222011528459656738731],
            [21847035105528745403288232691147584728191162732299865338377159692350059136679,
             10505242626370262277552901082094356697409835680220590971873171140371331206856]
        );

        return Pairing.pairingTest(p1Inputs, p2Inputs);
    }


    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(
            20491192805390485299153009773594534940189261866228447918068658471970481763042,
            9383485363053290200918347156157836566562967994039712273449902621266178545958
        );

        vk.beta2 = Pairing.G2Point(
            [4252822878758300859123897981450591353533073413197771768651442665752259397132,
             6375614351688725206403948262868962793625744043794305715222011528459656738731],
            [21847035105528745403288232691147584728191162732299865338377159692350059136679,
             10505242626370262277552901082094356697409835680220590971873171140371331206856]
        );
        vk.gamma2 = Pairing.G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
        vk.delta2 = Pairing.G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
        vk.IC = new Pairing.G1Point[](2);
        
        vk.IC[0] = Pairing.G1Point( 
            6819801395408938350212900248749732364821477541620635511814266536599629892365,
            9092252330033992554755034971584864587974280972948086568597554018278609861372
        );                                      
        
        vk.IC[1] = Pairing.G1Point( 
            17882351432929302592725330552407222299541667716607588771282887857165175611387,
            18907419617206324833977586007131055763810739835484972981819026406579664278293
        );                                      
        
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        
        require(input.length + 1 == vk.IC.length,"verifier-bad-input");
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);

        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field,"verifier-gte-snark-scalar-field");
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        }

        return input.length;
        
        // vk_x = Pairing.addition(vk_x, vk.IC[0]);
        // if (!Pairing.pairingProd4(
        //     Pairing.negate(proof.A), proof.B,
        //     vk.alfa1, vk.beta2,
        //     vk_x, vk.gamma2,
        //     proof.C, vk.delta2
        // )) return 1;
        // return 0;
    }
    /// @return r  bool true if proof is valid
    function verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (uint r) {
        
        Proof memory proof;

        
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
        

        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        return verify(inputValues, proof);

        // if (verify(inputValues, proof) == 0) {
        //     return true;
        // } else {
        //     return false;
        // }
    }
}
