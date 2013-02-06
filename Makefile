HARNESS=prove -v
TESTS=$(wildcard t/*.t)

test:
	${HARNESS} ${TESTS}
