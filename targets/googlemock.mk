sources += ${GOOGLEMOCK_DIR}/gtest/src/gtest-all.cc \
	${GOOGLEMOCK_DIR}/src/gmock-all.cc ${GOOGLEMOCK_DIR}/src/gmock_main.cc
includes += -I${GOOGLEMOCK_DIR}/gtest/include -I${GOOGLEMOCK_DIR}/gtest \
	-I${GOOGLEMOCK_DIR}/include -I${GOOGLEMOCK_DIR}/ \

LDFLAGS += -pthread
