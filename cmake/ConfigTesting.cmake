find_program(VALGRIND_EXECUTABLE valgrind)
if (VALGRIND_EXECUTABLE)
	set(MEMORYCHECK_COMMAND ${VALGRIND_EXECUTABLE})
	set(CTEST_MEMORYCHECK_COMMAND ${VALGRIND_EXECUTABLE})
	set(MEMORYCHECK_COMMAND_OPTIONS "--leak-check=full")
	set(MEMORYCHECK_SUPPRESSIONS_FILE 
		${CMAKE_BINARY_DIR}/valgrind.supp)
endif()
mark_as_advanced(VALGRIND_EXECUTABLE)

if (EXISTS ${CMAKE_SOURCE_DIR}/CTestConfig.cmake)
	configure_file(${CMAKE_SOURCE_DIR}/CTestCustom.cmake.in
		${CMAKE_BINARY_DIR}/CTestCustom.cmake @ONLY)
	include(CTest)
	if (EXISTS ${CMAKE_SOURCE_DIR}/Dashboard)
		add_subdirectory(Dashboard)
	endif()
endif()

enable_testing()

set(BUILDNAME ${BUILDNAME}
	CACHE STRING "Name of build on the dashboard"
	)

if (ENABLE_GTEST)
	find_package(GTest)
endif()
