sources += ${GTEST_DIR}/src/gtest-all.cc ${GTEST_DIR}/src/gtest_main.cc
includes += -I${GTEST_DIR}/include -I${GTEST_DIR}/
LDFLAGS += -pthread
