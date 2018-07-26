#include "Core.hpp"

namespace E3T
{
	static void error_callback(int error, const char* description)
	{
		fprintf(stderr, "Error(%d): %s\n", error, description);
		__debugbreak();
	}
	void init_glfw()
	{
		if (!glfwInit())
		{
			DEBUG_FATA_ERROR("Failed to initialize GLFW");
		}
		glfwSetErrorCallback(error_callback);
		std::atexit(glfwTerminate);
	}
	void init_glad()
	{
		if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
		{
			DEBUG_FATA_ERROR("Failed to initialize GLAD");
		}
		glEnable(GL_MULTISAMPLE);
	}
	GLFWwindow* createWindow(int width, int height, const char *name, int samples)
	{
		if (samples > 1) { glfwWindowHint(GLFW_SAMPLES, samples); }
		glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
		glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
		glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GLFW_TRUE);
		GLFWwindow* pWindow{ glfwCreateWindow(width, height, name, nullptr, nullptr) };

		if (!pWindow)
		{
			DEBUG_FATA_ERROR("Failed to create GLFWWindow");
		}
		return pWindow;
	}
}