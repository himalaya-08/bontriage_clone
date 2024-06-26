/**
 * \file
 * Functions and types for CRC checks.
 *
 * Generated on Sat Feb 29 02:30:42 2020
 * by pycrc v0.9.2, https://pycrc.org
 * using the configuration:
 *  - Width         = 12
 *  - Poly          = 0x80f
 *  - XorIn         = 0x000
 *  - ReflectIn     = False
 *  - XorOut        = 0x000
 *  - ReflectOut    = True
 *  - Algorithm     = table-driven
 */

#include "crc12_3gpp.h"

/**
 * Static table used for the table_driven implementation.
 */
static const crc12_t crc12_table[256] = {
    0x000, 0x80f, 0x811, 0x01e, 0x82d, 0x022, 0x03c, 0x833, 0x855, 0x05a, 0x044, 0x84b, 0x078, 0x877, 0x869, 0x066,
    0x8a5, 0x0aa, 0x0b4, 0x8bb, 0x088, 0x887, 0x899, 0x096, 0x0f0, 0x8ff, 0x8e1, 0x0ee, 0x8dd, 0x0d2, 0x0cc, 0x8c3,
    0x945, 0x14a, 0x154, 0x95b, 0x168, 0x967, 0x979, 0x176, 0x110, 0x91f, 0x901, 0x10e, 0x93d, 0x132, 0x12c, 0x923,
    0x1e0, 0x9ef, 0x9f1, 0x1fe, 0x9cd, 0x1c2, 0x1dc, 0x9d3, 0x9b5, 0x1ba, 0x1a4, 0x9ab, 0x198, 0x997, 0x989, 0x186,
    0xa85, 0x28a, 0x294, 0xa9b, 0x2a8, 0xaa7, 0xab9, 0x2b6, 0x2d0, 0xadf, 0xac1, 0x2ce, 0xafd, 0x2f2, 0x2ec, 0xae3,
    0x220, 0xa2f, 0xa31, 0x23e, 0xa0d, 0x202, 0x21c, 0xa13, 0xa75, 0x27a, 0x264, 0xa6b, 0x258, 0xa57, 0xa49, 0x246,
    0x3c0, 0xbcf, 0xbd1, 0x3de, 0xbed, 0x3e2, 0x3fc, 0xbf3, 0xb95, 0x39a, 0x384, 0xb8b, 0x3b8, 0xbb7, 0xba9, 0x3a6,
    0xb65, 0x36a, 0x374, 0xb7b, 0x348, 0xb47, 0xb59, 0x356, 0x330, 0xb3f, 0xb21, 0x32e, 0xb1d, 0x312, 0x30c, 0xb03,
    0xd05, 0x50a, 0x514, 0xd1b, 0x528, 0xd27, 0xd39, 0x536, 0x550, 0xd5f, 0xd41, 0x54e, 0xd7d, 0x572, 0x56c, 0xd63,
    0x5a0, 0xdaf, 0xdb1, 0x5be, 0xd8d, 0x582, 0x59c, 0xd93, 0xdf5, 0x5fa, 0x5e4, 0xdeb, 0x5d8, 0xdd7, 0xdc9, 0x5c6,
    0x440, 0xc4f, 0xc51, 0x45e, 0xc6d, 0x462, 0x47c, 0xc73, 0xc15, 0x41a, 0x404, 0xc0b, 0x438, 0xc37, 0xc29, 0x426,
    0xce5, 0x4ea, 0x4f4, 0xcfb, 0x4c8, 0xcc7, 0xcd9, 0x4d6, 0x4b0, 0xcbf, 0xca1, 0x4ae, 0xc9d, 0x492, 0x48c, 0xc83,
    0x780, 0xf8f, 0xf91, 0x79e, 0xfad, 0x7a2, 0x7bc, 0xfb3, 0xfd5, 0x7da, 0x7c4, 0xfcb, 0x7f8, 0xff7, 0xfe9, 0x7e6,
    0xf25, 0x72a, 0x734, 0xf3b, 0x708, 0xf07, 0xf19, 0x716, 0x770, 0xf7f, 0xf61, 0x76e, 0xf5d, 0x752, 0x74c, 0xf43,
    0xec5, 0x6ca, 0x6d4, 0xedb, 0x6e8, 0xee7, 0xef9, 0x6f6, 0x690, 0xe9f, 0xe81, 0x68e, 0xebd, 0x6b2, 0x6ac, 0xea3,
    0x660, 0xe6f, 0xe71, 0x67e, 0xe4d, 0x642, 0x65c, 0xe53, 0xe35, 0x63a, 0x624, 0xe2b, 0x618, 0xe17, 0xe09, 0x606
};

crc12_t crc_reflect(crc12_t data, size_t data_len)
{
	unsigned int i;
	crc12_t ret = data & 0x01;

	for (i = 1; i < data_len; i++)
	{
		data >>= 1;
		ret = (ret << 1) | (data & 0x01);
	}

	return ret;
}

crc12_t crc12_3gpp_update(crc12_t crc, const void *data, size_t data_len)
{
	const unsigned char *d = (const unsigned char *)data;
	unsigned int tbl_idx;

	while (data_len--)
	{
		tbl_idx = ((crc >> 4) ^ *d) & 0xff;
		crc = (crc12_table[tbl_idx] ^ (crc << 8)) & 0xfff;
		d++;
	}

	return crc & 0xfff;
}
