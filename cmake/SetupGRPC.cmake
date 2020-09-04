
find_program(gRPC_CPP_PLUGIN_EXECUTABLE grpc_cpp_plugin${CMAKE_EXECUTABLE_SUFFIX}
             HINTS ${CONAN_BIN_DIRS}
                   ${CONAN_BIN_DIRS_DEBUG}
                   ${CONAN_BIN_DIRS_RELEASE}
                   ${CONAN_BIN_DIRS_RELWITHDEBINFO}
             NO_DEFAULT_PATH)

# get_target_property(gRPC_CPP_PLUGIN_EXECUTABLE gRPC::grpc_cpp_plugin IMPORTED_LOCATION_RELEASE)
# get_target_property(gRPC_CPP_PLUGIN_EXECUTABLE CONAN_PKG::grpc::grpc_cpp_plugin IMPORTED_LOCATION_RELEASE)
