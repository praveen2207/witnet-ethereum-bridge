pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "truffle/Assert.sol";
import "../contracts/CBOR.sol";


contract TestCBOR {
  using CBOR for CBOR.Value;

  event Log(string _topic, uint256 _value);
  event Log(string _topic, bytes _value);

  function testUint64DecodeDiscriminant() public {
    CBOR.Value memory decoded = CBOR.valueFromBytes(hex"1b0020000000000000");
    Assert.equal(uint(decoded.majorType), 0, "CBOR-encoded Uint64 value should be decoded into a CBOR.Value with major type 0");
  }

  function testUint64DecodeValue() public {
    uint64 decoded = CBOR.valueFromBytes(hex"1b0020000000000000").decodeUint64();
    Assert.equal(
      uint(decoded),
      9007199254740992,
      "CBOR-encoded Uint64 value should be decoded into a CBOR.Value containing the correct Uint64 value"
    );
  }

  function testInt128DecodeDiscriminant() public {
    CBOR.Value memory decoded = CBOR.valueFromBytes(hex"3bfffffffffffffffe");
    Assert.equal(uint(decoded.majorType), 1, "CBOR-encoded Int128 value should be decoded into a CBOR.Value with major type 1");
  }

  function testInt128DecodeValue() public {
    int128 decoded = CBOR.valueFromBytes(hex"3bfffffffffffffffe").decodeInt128();
    Assert.equal(
      int(decoded),
      -18446744073709551615,
      "CBOR-encoded Int128 value should be decoded into a CBOR.Value containing the correct Uint64 value"
    );
  }

  function testInt128DecodeZeroValue() public {
    int128 decoded = CBOR.valueFromBytes(hex"00").decodeInt128();
    Assert.equal(int(decoded), 0, "CBOR-encoded Int128 value should be decoded into a CBOR.Value containing the correct Uint64 value");
  }

  function testBytes0DecodeDiscriminant() public {
    CBOR.Value memory decoded = CBOR.valueFromBytes(hex"40");
    Assert.equal(uint(decoded.majorType), 2, "Empty CBOR-encoded Bytes value should be decoded into a CBOR.Value with major type 2");
  }

  function testBytes0DecodeValue() public {
    bytes memory encoded = hex"40";
    bytes memory decoded = CBOR.valueFromBytes(encoded).decodeBytes();
    Assert.equal(decoded.length, 0, "Empty CBOR-encoded Bytes value should be decoded into an empty CBOR.Value containing an empty bytes value");
  }

  function testBytes4BDecodeDiscriminant() public {
    CBOR.Value memory decoded = CBOR.valueFromBytes(hex"4401020304");
    Assert.equal(uint(decoded.majorType), 2, "CBOR-encoded Bytes value should be decoded into a CBOR.Value with major type 2");
  }

  function testBytes4DecodeValue() public {
    bytes memory encoded = hex"4401020304";
    bytes memory decoded = CBOR.valueFromBytes(encoded).decodeBytes();
    bytes memory expected = abi.encodePacked(
      uint8(1),
      uint8(2),
      uint8(3),
      uint8(4)
    );

    Assert.equal(
      decoded[0],
      expected[0],
      "CBOR-encoded Bytes value should be decoded into a CBOR.Value containing the correct Bytes value (error at item 0)"
    );
    Assert.equal(
      decoded[1],
      expected[1],
      "CBOR-encoded Bytes value should be decoded into a CBOR.Value containing the correct Bytes value (error at item 1)"
    );
    Assert.equal(
      decoded[2],
      expected[2],
      "CBOR-encoded Bytes value should be decoded into a CBOR.Value containing the correct Bytes value (error at item 2)"
    );
    Assert.equal(
      decoded[3],
      expected[3],
      "CBOR-encoded Bytes value should be decoded into a CBOR.Value containing the correct Bytes value (error at item 3)"
    );
  }

  function testStringDecodeDiscriminant() public {
    CBOR.Value memory decoded = CBOR.valueFromBytes(hex"6449455446");
    Assert.equal(uint(decoded.majorType), 3, "CBOR-encoded String value should be decoded into a CBOR.Value with major type 3");
  }

  function testStringDecodeValue() public {
    bytes memory encoded = hex"6449455446";
    string memory decoded = CBOR.valueFromBytes(encoded).decodeString();
    string memory expected = "IETF";

    Assert.equal(decoded, expected, "CBOR-encoded String value should be decoded into a CBOR.Value containing the correct String value");
  }

  function testFloatDecodeDiscriminant() public {
    CBOR.Value memory decoded = CBOR.valueFromBytes(hex"f90001");
    Assert.equal(uint(decoded.majorType), 7, "CBOR-encoded Float value should be decoded into a CBOR with major type 7");
  }

  function testFloatDecodeSmallestSubnormal() public {
    bytes memory encoded = hex"f90001";
    int32 decoded = CBOR.valueFromBytes(encoded).decodeFixed16();
    int32 expected = 0;

    Assert.equal(decoded, expected, "CBOR-encoded Float value should be decoded into a CBOR.Value containing the correct Float value");
  }

  function testFloatDecodeLargestSubnormal() public {
    bytes memory encoded = hex"f903ff";
    int32 decoded = CBOR.valueFromBytes(encoded).decodeFixed16();
    int32 expected = 0;

    Assert.equal(decoded, expected, "CBOR-encoded Float value should be decoded into a CBOR.Value containing the correct Float value");
  }

  function testFloatDecodeSmallestPositiveNormal() public {
    bytes memory encoded = hex"f90400";
    int32 decoded = CBOR.valueFromBytes(encoded).decodeFixed16();
    int32 expected = 0;

    Assert.equal(decoded, expected, "CBOR-encoded Float value should be decoded into a CBOR.Value containing the correct Float value");
  }

  function testFloatDecodeLargestNormal() public {
    bytes memory encoded = hex"f97bff";
    int32 decoded = CBOR.valueFromBytes(encoded).decodeFixed16();
    int32 expected = 655040000;

    Assert.equal(decoded, expected, "CBOR-encoded Float value should be decoded into a CBOR.Value containing the correct Float value");
  }

  function testFloatDecodeLargestLessThanOne() public {
    bytes memory encoded = hex"f93bff";
    int32 decoded = CBOR.valueFromBytes(encoded).decodeFixed16();
    int32 expected = 9995;

    Assert.equal(decoded, expected, "CBOR-encoded Float value should be decoded into a CBOR.Value containing the correct Float value");
  }

  function testFloatDecodeOne() public {
    bytes memory encoded = hex"f93c00";
    int32 decoded = CBOR.valueFromBytes(encoded).decodeFixed16();
    int32 expected = 10000;

    Assert.equal(decoded, expected, "CBOR-encoded Float value should be decoded into a CBOR.Value containing the correct Float value");
  }

  function testFloatDecodeSmallestGreaterThanOne() public {
    bytes memory encoded = hex"f93c01";
    int32 decoded = CBOR.valueFromBytes(encoded).decodeFixed16();
    int32 expected = 10009;

    Assert.equal(decoded, expected, "CBOR-encoded Float value should be decoded into a CBOR.Value containing the correct Float value");
  }

  function testFloatDecodeOneThird() public {
    bytes memory encoded = hex"f93555";
    int32 decoded = CBOR.valueFromBytes(encoded).decodeFixed16();
    int32 expected = 3332;

    Assert.equal(decoded, expected, "CBOR-encoded Float value should be decoded into a CBOR.Value containing the correct Float value");
  }

  function testFloatDecodeMinusTwo() public {
    bytes memory encoded = hex"f9c000";
    int32 decoded = CBOR.valueFromBytes(encoded).decodeFixed16();
    int32 expected = -20000;

    Assert.equal(decoded, expected, "CBOR-encoded Float value should be decoded into a CBOR.Value containing the correct Float value");
  }

  function testFloatDecodeZero() public {
    bytes memory encoded = hex"f90000";
    int32 decoded = CBOR.valueFromBytes(encoded).decodeFixed16();
    int32 expected = 0;

    Assert.equal(decoded, expected, "CBOR-encoded Float value should be decoded into a CBOR.Value containing the correct Float value");
  }

  function testFloatDecodeMinusZero() public {
    bytes memory encoded = hex"f98000";
    int32 decoded = CBOR.valueFromBytes(encoded).decodeFixed16();
    int32 expected = 0;

    Assert.equal(decoded, expected, "CBOR-encoded Float value should be decoded into a CBOR.Value containing the correct Float value");
  }

  function testUint64ArrayDecode() public {
    bytes memory encoded = hex"840102031a002fefd8";
    uint64[] memory decoded = CBOR.valueFromBytes(encoded).decodeUint64Array();
    uint64[4] memory expected = [
      uint64(1),
      uint64(2),
      uint64(3),
      uint64(3141592)
    ];

    Assert.equal(
      uint(decoded[0]),
      uint(expected[0]),
      "CBOR-encoded Array of Uint64 values should be decoded into a CBOR.Value containing the correct Uint64 values (error at item 0)"
    );
    Assert.equal(
      uint(decoded[1]),
      uint(expected[1]),
      "CBOR-encoded Array of Uint64 values should be decoded into a CBOR.Value containing the correct Uint64 values (error at item 1)"
    );
    Assert.equal(
      uint(decoded[2]),
      uint(expected[2]),
      "CBOR-encoded Array of Uint64 values should be decoded into a CBOR.Value containing the correct Uint64 values (error at item 2)"
    );
    Assert.equal(
      uint(decoded[3]),
      uint(expected[3]),
      "CBOR-encoded Array of Uint64 values should be decoded into a CBOR.Value containing the correct Uint64 values (error at item 3)"
    );
  }

  function testInt128ArrayDecode() public {
    bytes memory encoded = hex"840121033a002fefd7";
    int128[] memory decoded = CBOR.valueFromBytes(encoded).decodeInt128Array();
    int128[4] memory expected = [
      int128(1),
      int128(-2),
      int128(3),
      int128(-3141592)
    ];

    Assert.equal(
      decoded[0],
      expected[0],
      "CBOR-encoded Array of Int128 values should be decoded into a CBOR.Value containing the correct Int128 values (error at item 0)"
    );
    Assert.equal(
      decoded[1],
      expected[1],
      "CBOR-encoded Array of Int128 values should be decoded into a CBOR.Value containing the correct Int128 values (error at item 1)"
    );
    Assert.equal(
      decoded[2],
      expected[2],
      "CBOR-encoded Array of Int128 values should be decoded into a CBOR.Value containing the correct Int128 values (error at item 2)"
    );
    Assert.equal(
      decoded[3],
      expected[3],
      "CBOR-encoded Array of Int128 values should be decoded into a CBOR.Value containing the correct Int128 values (error at item 3)"
    );
  }

  function testFixed16ArrayDecode() public {
    bytes memory encoded = hex"84f93c80f9c080f94290f9C249";
    int128[] memory decoded = CBOR.valueFromBytes(encoded).decodeFixed16Array();
    int128[4] memory expected = [
      int128(11250),int128(-22500),
      int128(32812),
      int128(-31425)
    ];

    Assert.equal(
      decoded[0],
      expected[0],
      "CBOR-encoded Array of Fixed16 values should be decoded into a CBOR.Value containing the correct Int128 values (error at item 0)"
    );
    Assert.equal(
      decoded[1],
      expected[1],
      "CBOR-encoded Array of Fixed16 values should be decoded into a CBOR.Value containing the correct Int128 values (error at item 1)"
    );
    Assert.equal(
      decoded[2],
      expected[2],
      "CBOR-encoded Array of Fixed16 values should be decoded into a CBOR.Value containing the correct Int128 values (error at item 2)"
    );
    Assert.equal(
      decoded[3],
      expected[3],
      "CBOR-encoded Array of Fixed16 values should be decoded into a CBOR.Value containing the correct Int128 values (error at item 3)"
    );
  }

  function testStringArrayDecode() public {
    bytes memory encoded = hex"846548656c6c6f6d646563656e7472616c697a656465776f726c646121";
    string[] memory decoded = CBOR.valueFromBytes(encoded).decodeStringArray();
    string[4] memory expected = [
      "Hello",
      "decentralized",
      "world",
      "!"
    ];

    Assert.equal(
      decoded[0],
      expected[0],
      "CBOR-encoded Array of String values should be decoded into a CBOR.Value containing the correct String values (error at item 0)"
    );
    Assert.equal(
      decoded[1],
      expected[1],
      "CBOR-encoded Array of String values should be decodrm -rf noed into a CBOR.Value containing the correct String values (error at item 1)"
    );
    Assert.equal(
      decoded[2],
      expected[2],
      "CBOR-encoded Array of String values should be decoded into a CBOR.Value containing the correct String values (error at item 2)"
    );
    Assert.equal(
      decoded[3],
      expected[3],
      "CBOR-encoded Array of String values should be decoded into a CBOR.Value containing the correct String values (error at item 3)"
    );
  }
}
