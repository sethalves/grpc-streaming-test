set(CMAKE_CONFIGURATION_TYPES "Debug;Release;RelWithDebInfo")
cmake_minimum_required(VERSION 3.12)

if (WIN32)
    # conan grpc can't build with cmake 3.16 or newer on Windows
    # https://github.com/inexorgame/conan-grpc/issues/39
    # https://gitlab.kitware.com/cmake/cmake/-/issues/20209
    if (${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.16")
        message(FATAL_ERROR "conan package grpc won't build on windows with cmake 3.16 or newer.")
    endif ()

    # grpc says: "Please compile grpc with _WIN32_WINNT of at least 0x600 (aka Windows Vista)" without this
    # https://github.com/inexorgame/conan-grpc/issues/17
    # https://github.com/inexorgame/conan-grpc/pull/30
    add_definitions(-D_WIN32_WINNT=0x600)
endif ()

project(hellostreamingworld_project)

# if (NOT GENERATOR_IS_MULTI_CONFIG AND NOT CMAKE_BUILD_TYPE)
if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_GENERATOR MATCHES "^Visual Studio.*")
    set(CMAKE_BUILD_TYPE "Release")
endif ()

option(CONAN_BUILD_ALL "set ON to not use prebuilt binaries for dependencies" OFF)

if (CONAN_BUILD_ALL)
    set(CONAN_BUILD_POLICY "all")
else ()
    set(CONAN_BUILD_POLICY "missing")
endif ()

cmake_policy(SET CMP0074 NEW)

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/conan.cmake")
conan_add_remote(NAME bincrafters INDEX 1 URL https://api.bintray.com/conan/bincrafters/public-conan)
conan_add_remote(NAME inexorgame INDEX 1 URL https://api.bintray.com/conan/inexorgame/inexor-conan)
conan_cmake_run(CONFIGURATION_TYPES "Debug;Release;RelWithDebInfo" # OUTPUT_QUIET
                BASIC_SETUP CMAKE_TARGETS BUILD ${CONAN_BUILD_POLICY}
                REQUIRES
                  protobuf/3.9.1
                  grpc/1.25.0@inexorgame/stable
                  )

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/Compiler.cmake")
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/MemoryDebugger.cmake")
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/SetupProtobuf.cmake")
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/SetupGRPC.cmake")

setup_memory_debugger()

#####
##### define protocol
#####

get_filename_component(hellostreamingworld_proto_file "hellostreamingworld.proto" ABSOLUTE)
get_filename_component(hellostreamingworld_proto_file_path "${hellostreamingworld_proto_file}" PATH)

protobuf_generate_cpp(hellostreamingworld_proto_srcs hellostreamingworld_proto_hdrs "${hellostreamingworld_proto_file}")
set(hellostreamingworld_grpc_srcs "${CMAKE_CURRENT_BINARY_DIR}/hellostreamingworld.grpc.pb.cc")
set(hellostreamingworld_grpc_hdrs "${CMAKE_CURRENT_BINARY_DIR}/hellostreamingworld.grpc.pb.h")
add_custom_command(
      OUTPUT "${hellostreamingworld_grpc_srcs}" "${hellostreamingworld_grpc_hdrs}"
      COMMAND protobuf::protoc
      ARGS --grpc_out "${CMAKE_CURRENT_BINARY_DIR}" -I "${hellostreamingworld_proto_file_path}"
        --plugin=protoc-gen-grpc="${gRPC_CPP_PLUGIN_EXECUTABLE}"
        "${hellostreamingworld_proto_file}"
      DEPENDS "${hellostreamingworld_proto_file}")



set(hellostreamingworld_proto_src_public "${hellostreamingworld_proto_hdrs};${hellostreamingworld_grpc_hdrs}")
set(hellostreamingworld_proto_src_core "${hellostreamingworld_proto_srcs};${hellostreamingworld_grpc_srcs}")

add_library(protocol_library STATIC ${hellostreamingworld_proto_src_public} ${hellostreamingworld_proto_src_core}) 

setup_memory_debugger()

# help visual studio show the source files in a nice way
source_group("public" FILES ${hellostreamingworld_proto_src_public})
source_group("core" FILES ${hellostreamingworld_proto_src_core})

target_include_directories(protocol_library PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_include_directories(protocol_library PUBLIC ${CMAKE_CURRENT_BINARY_DIR})
target_link_libraries(protocol_library CONAN_PKG::grpc CONAN_PKG::protobuf)

install(TARGETS protocol_library DESTINATION lib)
install(FILES ${hellostreamingworld_proto_src_public} DESTINATION include)

#####
##### server
#####

add_executable(async_streaming_server async_streaming_server.cc)
target_link_libraries(async_streaming_server PRIVATE protocol_library CONAN_PKG::grpc CONAN_PKG::protobuf)


#####
##### client
#####

add_executable(greeter_streaming_client greeter_streaming_client.cc)
target_link_libraries(greeter_streaming_client PRIVATE protocol_library CONAN_PKG::grpc CONAN_PKG::protobuf)
