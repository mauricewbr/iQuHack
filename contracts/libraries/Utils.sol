pragma solidity ^0.7.0;

library LibUtils {
    // uint16[16] /*constant*/ private FALCON_PUBKEY_SIZE            = [5,5,8,15,29,57,113,225,449,897,1793,3585,7169,14337,28673,57345];
    uint32 constant private Q   = 12289;
    uint32 constant private Q0I = 12287;

    ////////////////////////////////////////
    // Solidity implementation of the macro...
    // #define ROL(a, offset) (((a) << (offset)) ^ ((a) >> (64 - (offset))))
    ////////////////////////////////////////
    function ROL(uint64 a, uint16 offset) public pure returns (uint64)
    {
        return (((a) << (offset)) ^ ((a) >> (64 - (offset))));
    }

    // ///////////////////////////////////////
    // // Public key size (in bytes). The size is exact.
    // // #define FALCON_PUBKEY_SIZE(logn) (((logn) <= 1 ? 4u : (7u << ((logn) - 2))) + 1)
    // ///////////////////////////////////////
    // function falconPubkeySize(uint8 logn) external private view returns (uint16)
    // {
    //     if (logn > 15)
    //         logn = 15;
    //     return FALCON_PUBKEY_SIZE[logn];
    // }

    ////////////////////////////////////////
    // Addition modulo q. Operands must be in the 0..q-1 range.
    ////////////////////////////////////////
    function mq_add(uint32 x, uint32 y) public pure returns (uint32 result)
    {
        uint32    d;

        d = x + y - Q;
        d += Q & -(d >> 31);
        result = d;
    }

    ////////////////////////////////////////
    // Subtraction modulo q. Operands must be in the 0..q-1 range.
    ////////////////////////////////////////
    function mq_sub(uint32 x, uint32 y) public pure returns (uint32 result)
    {
         // As in mq_add(), we use a conditional addition to ensure the result is in the 0..q-1 range.
        uint32    d;

        d = x - y;
        d += Q & -(d >> 31);
        return d;
    }

    ////////////////////////////////////////
    // Division by 2 modulo q. Operand must be in the 0..q-1 range.
    ////////////////////////////////////////
    function mq_rshift1(uint32 x) public pure returns (uint32 result)
    {
        x += Q & -(x & 1);
        return (x >> 1);
    }

    ////////////////////////////////////////
    // Montgomery multiplication modulo q. If we set R = 2^16 mod q, then this function computes: x * y / R mod q
    // Operands must be in the 0..q-1 range.
    ////////////////////////////////////////
    function mq_montymul(uint32 x, uint32 y) public pure returns (uint32 result)
    {
        uint32    z;
        uint32    w;

        z = x * y;
        w = ((z * Q0I) & 0xFFFF) * Q;
        z = (z + w) >> 16;
        z -= Q;
        z += Q & -(z >> 31);
        return z;
    }

    function PQCLEAN_FALCON512_CLEAN_is_short(uint16[] memory s1, int16[] memory s2, uint32 logn) public pure returns (int16)
    {
        uint32 n;
        uint32 u;
        uint32 s;
        uint32 ng;

        n = uint32(1) << logn;
        s = 0;
        ng = 0;
        for (u = 0; u < n; u++)
        {
            uint16 z;

            z = s1[u];
            s += uint32(z * z);
            ng |= s;

            z = uint16(s2[u]);
            s += uint32(z * z);
            ng |= s;
        }

        s |= -(ng >> 31);

        uint32 val = ((uint32(7085) * uint32(12289)) >> (10 - logn));
        if (s < val)
           return 1;
        return 0; // //return s < ((uint32(7085) * uint32(12289)) >> (10 - logn));
    }

    function PQCLEAN_FALCON512_CLEAN_modq_decode(uint16[] memory pX, uint16 logn, uint8[] memory pInput, uint16 In_offset, uint16 cbInputMax)  public pure returns (uint16)
    {
        uint16        n;
        uint16        In_len;
        uint16        u;
        uint16        buf_ndx;
        uint16        acc;
        uint16        acc_len;

        n = uint16(1) << logn;
        In_len = ((n * 14) + 7) >> 3;
        if (In_len > cbInputMax)
        {
            return 0;
        }

        buf_ndx = 0;
        acc     = 0;
        acc_len = 0;
        u       = 0;

        while (u < n)
        {
            acc = (acc << 8) | uint16(uint8(pInput[In_offset + buf_ndx++]));   // acc = (acc << 8) | (*buf++);
            acc_len += 8;
            if (acc_len >= 14)
            {
                uint16 w;

                acc_len -= 14;
                w = (acc >> acc_len) & 0x3FFF;
                if (w >= 12289)
                {
                    return 0;
                }
                pX[u++] = uint16(w);
                u++;
            }
        }

        if ((acc & ((uint32(1) << acc_len) - 1)) != 0)
        {
            return 0;
        }

        return In_len;
    }

    function PQCLEAN_FALCON512_CLEAN_comp_decode(int16[] memory pOutput, uint16 logn, uint8[] memory pInput, uint16 cbInputMax) public pure returns (uint16)
    {
        uint16  n;
        uint16  u;
        uint16  v;
        uint32  acc;
        uint16  acc_len;

        n = uint16(1) << logn;

        acc = 0;
        acc_len = 0;
        v = 0;

        for (u = 0; u < n; u++)
        {
            uint16 b;
            uint16 s;
            uint16 m;

            if (v >= cbInputMax)
            {
                return 0;
            }

            uint16 aaa = uint16(uint32(pInput[v++]));
            acc = (acc << 8) | aaa;                          // acc = (acc << 8) | uint32(buf[v++]);

            b = uint16(acc >> acc_len);
            s = b & 128;
            m = b & 127;

            for (;;)
            {
                if (acc_len == 0)
                {
                    if (v >= cbInputMax)
                    {
                        return 0;
                    }
                    acc = (acc << 8) | uint32(pInput[v++]); // acc = (acc << 8) | uint32(buf[v++]);
                    acc_len = 8;
                }

                acc_len--;
                if (((acc >> acc_len) & 1) != 0)
                {
                    break;
                }

                m += 128;
                if (m > 2047)
                {
                    return 0;
                }
            }

            int16 val = int16((s!=0) ? -int(m) : int(m));
            pOutput[u] = val;                               // pOutput[u] = int16(s ? -int(m) : int(m));

        } // For
        return v;
    }
}