PERL := perl

all: update-ca-certificates c_rehash certdata.stamp

update-ca-certificates: update-ca.c
	${CC} ${CFLAGS} -o $@ update-ca.c ${LDFLAGS}

c_rehash: c_rehash.c
	${CC} ${CFLAGS} -o $@ c_rehash.c -lcrypto ${LDFLAGS}

cert.pem: mk-ca-bundle.pl
	${PERL} mk-ca-bundle.pl -n -w 64 $@

certdata.stamp: cert.pem split-ca-bundle.sh
	${SHELL} split-ca-bundle.sh < cert.pem
	touch $@

install: all
	install -d -m755 ${DESTDIR}/etc/ca-certificates/update.d \
		${DESTDIR}/usr/bin \
		${DESTDIR}/usr/sbin \
		${DESTDIR}/usr/share/ca-certificates \
		${DESTDIR}/usr/local/share/ca-certificates \
		${DESTDIR}/etc/ssl/certs

	for cert in *.crt; do \
		install -D -m644 $$cert ${DESTDIR}/usr/share/ca-certificates/mozilla/$$cert; \
	done

	install -D -m644 update-ca-certificates.8 ${DESTDIR}/usr/share/man/man8/update-ca-certificates.8
	install -m755 update-ca-certificates ${DESTDIR}/usr/sbin
	install -m755 c_rehash ${DESTDIR}/usr/bin

clean:
	rm -rf update-ca-certificates c_rehash certdata.stamp *.crt cert.pem

# https://hg.mozilla.org/mozilla-central/file/tip/security/nss/lib/ckfw/builtins/certdata.txt
update:
	curl https://hg.mozilla.org/mozilla-central/raw-file/tip/security/nss/lib/ckfw/builtins/certdata.txt > certdata.txt

.PHONY: install clean update
