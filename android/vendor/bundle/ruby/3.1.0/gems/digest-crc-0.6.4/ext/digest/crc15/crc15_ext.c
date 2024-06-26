#include <ruby.h>
#include "../compat/ruby.h"

#include "extconf.h"
#include "crc15.h"

VALUE Digest_CRC15_update(VALUE self, VALUE data)
{
	VALUE crc_ivar_name = rb_intern("@crc");
	VALUE crc_ivar = rb_ivar_get(self, crc_ivar_name);
	crc15_t crc = NUM2USHORT(crc_ivar);

	const char *data_ptr = StringValuePtr(data);
	size_t length = RSTRING_LEN(data);

	crc = crc15_update(crc,data_ptr,length);

	rb_ivar_set(self, crc_ivar_name, USHORT2NUM(crc));
	return self;
}

void Init_crc15_ext()
{
	VALUE mDigest = rb_const_get(rb_cObject, rb_intern("Digest"));
	VALUE cCRC15 = rb_const_get(mDigest, rb_intern("CRC15"));

	rb_undef_method(cCRC15, "update");
	rb_define_method(cCRC15, "update", Digest_CRC15_update, 1);
}
