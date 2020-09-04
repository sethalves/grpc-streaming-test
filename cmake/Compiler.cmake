set(CMAKE_CXX_FLAGS_DEBUG  "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG")
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

if (NOT "${CMAKE_SIZEOF_VOID_P}" EQUAL "8")
    message( FATAL_ERROR "Only 64 bit builds supported." )
endif()


if (WIN32)
    # make _cplusplus macro be for-real
    # https://docs.microsoft.com/en-us/cpp/build/reference/zc-cplusplus?view=vs-2019
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zc:__cplusplus")

    # don't complain about missing pdb files in dependencies
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /ignore:4099")
else ()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -fno-strict-aliasing -Wno-unused-parameter")
    if (CMAKE_CXX_COMPILER_ID MATCHES "GNU")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ggdb -Woverloaded-virtual -Wdouble-promotion")
        if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "5.1") # gcc 5.1 and on have suggest-override
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wsuggest-override")
        endif ()
    endif ()
endif ()
