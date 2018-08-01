#pragma once
#include <iostream>
#include <string>
#include <chrono>
#include <algorithm>

struct Timer
{
	std::chrono::time_point<std::chrono::steady_clock> start, end;
	std::chrono::duration<float> duration;
	Timer()
		: start(std::chrono::high_resolution_clock::now())
	{}
	~Timer()
	{
		end = std::chrono::high_resolution_clock::now();
		duration = end - start;
		float ms = duration.count() * 1000.0f;
		std::cout << "Timer took " << ms << "ms" << std::endl;
	}
};

#define FATA_ERROR(errorMsg) std::cerr << "[Error] (" << errorMsg << "):\n" << __FILE__ << ':' << __LINE__ << std::endl; std::exit(-1)

#ifdef _DEBUG
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
		std::cerr << "[OpenGL Error] (" << errorMsg << ") " << #x << ":\n" << __FILE__ << ':' << __LINE__ << std::endl; \
		error = true; \
	}\
}
#else
#define GLCall(x) x
#endif