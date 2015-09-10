sources += ${GOOGLETEST_DIR}/src/gtest-all.cc ${GOOGLETEST_DIR}/src/gtest_main.cc
includes += -I${GOOGLETEST_DIR}/include -I${GOOGLETEST_DIR}/
LDFLAGS += -pthread
