#ifndef _CRC32_JAM_H_
#define _CRC32_JAM_H_

#include "../crc32/crc32.h"

crc32_t crc32_jam_update(crc32_t crc, const void *data, size_t data_len);

#endif
