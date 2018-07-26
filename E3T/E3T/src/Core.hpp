#pragma once
#include "Macros.hpp"
#include "Shader.hpp"
#include "Timer.hpp"
#include "Cam.hpp"
#include <glad\glad.h>
#include <GLFW\glfw3.h>
#include <iostream>
#include <cassert>
#include <intrin.h>

namespace E3T
{
	extern void init_glfw() noexcept;
	extern void init_glad() noexcept;
	extern GLFWwindow* createWindow(int width, int height, const char *name, int samples = 1) noexcept;
}