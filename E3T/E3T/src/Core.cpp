#include "Core.hpp"

namespace E3T
{
	static void error_callback(int error, const char* description) noexcept
	{
		fprintf(stderr, "Error(%d): %s\n", error, description);
		__debugbreak();
	}
	void init_glfw() noexcept
	{
		if (!glfwInit())
		{
			FATA_ERROR("Failed to initialize GLFW");
		}
		glfwSetErrorCallback(error_callback);
	}
	void init_glad() noexcept
	{
		if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
		{
			FATA_ERROR("Failed to initialize GLAD");
		}
	}
	void init_imgui(GLFWwindow *pWindow) noexcept
	{
		ImGui::CreateContext();
		ImGui_ImplGlfw_InitForOpenGL(pWindow, true);
		ImGui_ImplOpenGL3_Init();
		ImGui::StyleColorsClassic();
	}
	GLFWwindow* createWindow(int width, int height, const char *name) noexcept
	{
		glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
		glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
		glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GLFW_TRUE);
		GLFWwindow* pWindow{ glfwCreateWindow(width, height, name, nullptr, nullptr) };

		if (!pWindow)
		{
			FATA_ERROR("Failed to create GLFWWindow");
		}
		return pWindow;
	}
	void shutdown()
	{
		ImGui_ImplOpenGL3_Shutdown();
		ImGui_ImplGlfw_Shutdown();
		ImGui::DestroyContext();
		glfwTerminate();
	}
}