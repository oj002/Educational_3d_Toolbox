#pragma once
#include <iostream>
#include <string>
#include <intrin.h>

#ifdef _DEBUG
#define DEBUG_ASSERT(x) if (!(x)) { __debugbreak(); }
#define DEBUG_ERROR(errorCode) std::cerr << "[Error] (" << errorCode << "): \n" << __FILE__ << ':' << __LINE__ << std::endl; __debugbreak()
#define DEBUG_FATA_ERROR(errorCode) DEBUG_ERROR(errorCode); std::exit(-1)
#define GLCall(x) \
while (glGetError()){}\
x;\
if(true)\
{\
	bool error = false; \
	while (GLenum errorCode = glGetError())\
	{\
		std::string errorMsg;\
		switch (errorCode)\
		{\
			case GL_INVALID_ENUM:					errorMsg = "INVALID_ENUM"; break;\
			case GL_INVALID_VALUE:					errorMsg = "INVALID_VALUE"; break;\
			case GL_INVALID_OPERATION:				errorMsg = "INVALID_OPERATION"; break;\
			case GL_OUT_OF_MEMORY:					errorMsg = "OUT_OF_MEMORY"; break;\
			case GL_INVALID_FRAMEBUFFER_OPERATION:	errorMsg = "INVALID_FRAMEBUFFER_OPERATION"; break;\
			default:								errorMsg = std::to_string(errorCode); break;\
		}\
		std::cerr << "[OpenGL Error] (" << errorMsg << "): " << #x << " " << __FILE__ << ':' << __LINE__ << '\n'; \
		error = true; \
	}\
	if (error) { __debugbreak(); }\
}
#else
#define DEBUG_ASSERT(x)
#define DEBUG_ERROR(errorCode)
#define DEBUG_FATA_ERROR(errorCode)
#define GLCall(x) x
#endif