#https://streamcomputing.eu/blog/2015-09-25/handling-opencl-with-cmake-3-1-and-higher/
#https://www.khronos.org/registry/cl/
#Minimal OpenCL CMakeLists.txt by StreamComputing
#ubuntun clinfo : https://github.com/Oblomov/clinfo
#libdl.so
#一、 使用libdl.so库
#动态库加载原理
#动态库中函数的查找已经封装成哭libdl.so
#libdl.so里面有4个函数：
#dlopen//打开一个动态库
#dlsym//在打开的动态库里找一个函数
#dlclose//关闭动态库
#dlerror//返回错误

cmake_minimum_required (VERSION 3.1)
project(openCL)
# Handle OpenCL
find_package(OpenCL REQUIRED)
message("OpenCL_FOUND : ${OpenCL_FOUND}")
if(OpenCL_FOUND)
	message("OpenCL_INCLUDE_DIRS=${OpenCL_INCLUDE_DIRS}")
	message("OpenCL_LIBRARY=${OpenCL_LIBRARY}")
	include_directories(${OpenCL_INCLUDE_DIRS})
endif()

link_directories(${OpenCL_LIBRARY})
add_executable (clinfo src/clinfo.c)
target_include_directories (clinfo PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries (clinfo dl ${OpenCL_LIBRARY})
